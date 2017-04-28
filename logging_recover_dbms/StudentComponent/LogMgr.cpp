#include "LogMgr.h"
#include <sstream>
#include "../StorageEngine/StorageEngine.h"
#include <climits>
#include <algorithm>
#include <queue> 
using namespace std;

int LogMgr::getLastLSN(int txnum){
  // find the most recent tx from the tx_table
  if(tx_table.find(txnum) != tx_table.end()){
    return tx_table[txnum].lastLSN;
  }else{
    return NULL_LSN;
  }
}

void LogMgr::setLastLSN(int txnum, int lsn){
  if(tx_table.find(txnum) != tx_table.end()){
    // means has this txnum then just update
    tx_table[txnum].lastLSN = lsn; 
  }else{
    // we need to create the new txTableEntry
    txTableEntry ntxTE(lsn,U);
    tx_table[txnum] = ntxTE;
  }
}

/*
 * Force log records up to and including the one with the
 * maxLSN to disk. Don't forget to remove them from the
 * logtail once they're written!
*/
void LogMgr::flushLogTail(int maxLSN){
  int siz = logtail.size();
  int i = 0;
  // if this is samller than or equal the maxLSN
  while(i<siz){
    // flash the log to the disk
    if(logtail[i]->getLSN() > maxLSN){
      break;
    }
    se->updateLog(logtail[i]->toString());
    i++;
  }
  for (int j = 0; j < i; j ++){
    logtail.erase(logtail.begin());
  }
}
/* 
 * Run the analysis phase of ARIES.
 */
void LogMgr::analyze(vector <LogRecord*> log){
  // find the most recent check_begin if there is one
  int B_CKPT = NULL_LSN;
  int E_CKPT = NULL_LSN;
  

  for(int i = log.size() - 1;i >=0; i--){
    if(log[i]->getType() == BEGIN_CKPT){
      B_CKPT = i;
      break;
    }
    else if(log[i]->getType() == END_CKPT){
      E_CKPT = i;
    }
  }
  

  // if there is begin checkpoint
  if(B_CKPT != NULL_LSN){
    ChkptLogRecord * end_CKPT_Pointer = dynamic_cast<ChkptLogRecord *>(log[E_CKPT]);
    tx_table = end_CKPT_Pointer->getTxTable();
    dirty_page_table = end_CKPT_Pointer->getDirtyPageTable();
  }


  // modifying the tx and dirty table from the begin check point
  for(int i = B_CKPT + 1; i< log.size() ; i++){
    //skip end_point
    if(i != E_CKPT){
      //int pre_lsn = log[i]->getprevLSN();
      int txid = log[i]->getTxID();
      TxType t = log[i]->getType();
      int lsn =  log[i]->getLSN();
      if(t == UPDATE){
          setLastLSN(txid,lsn);
          UpdateLogRecord * updLog = dynamic_cast<UpdateLogRecord*> (log[i]);
          int pageID = updLog->getPageID();
          // if not found in the dirty dtale
          if(dirty_page_table.find(pageID) == dirty_page_table.end()){
            dirty_page_table[pageID] = lsn;
          }
      }
      else if(t == CLR){
          setLastLSN(txid,lsn);
          CompensationLogRecord * clrLog = dynamic_cast<CompensationLogRecord*>(log[i]);
          int pageID = clrLog->getPageID();
          // if not found in the dirty dtale
          if(dirty_page_table.find(pageID) == dirty_page_table.end()){
            dirty_page_table[pageID] = lsn;
          }
      }else if(t == COMMIT){
          setLastLSN(txid,lsn);
          tx_table[txid].status = C;
      }
      else if(t == ABORT){
          setLastLSN(txid,lsn);
      }
      else if(t == END){
          tx_table.erase(txid);
      }
    }
  }
}

/*
 * Run the redo phase of ARIES.
 * If the StorageEngine stops responding, return false.
 * Else when redo phase is complete, return true. 
 */
bool LogMgr::redo(vector <LogRecord*> log){
  //first find the oldest update in the dirty-table
  int oldest_lsn = INT_MAX;
  map<int,int>::iterator it;
  for(it = dirty_page_table.begin(); it!=dirty_page_table.end(); it++){
    if(it->second < oldest_lsn){
      oldest_lsn = it->second;
    }
  }

  //find the smallest lsn in log
  int oldest_lsn_idx = 0;  
  for(int i = 0; i < log.size(); i++){
    if(log[i]->getLSN() == oldest_lsn){
        oldest_lsn_idx = i;
        break;
    }
  }

  
  // iterate through the log 
  for(int i = oldest_lsn_idx; i<log.size() ; i++){
    bool toRedo = true;
    TxType t = log[i]->getType();
    if(t == UPDATE){  
        // if this is update
        UpdateLogRecord * updLog = dynamic_cast<UpdateLogRecord *> (log[i]);
        int pageID = updLog->getPageID();
        //check the constraint 
        int lsn = updLog->getLSN();
        int reclsn = dirty_page_table[pageID];

        if(dirty_page_table.find(pageID) == dirty_page_table.end()){
          toRedo = false;
        }else if(reclsn > lsn){
          toRedo = false;
        }else{
          int pageLSN = se->getLSN(pageID);
          if(pageLSN >= lsn){
            toRedo = false;
          }
        }
        
        //redo
        if(toRedo){
          if(!se->pageWrite(pageID,updLog->getOffset(),updLog->getAfterImage(),lsn)){
            return false;
          }
        }
      }
      else if (t == CLR){
        // if this is clr
        CompensationLogRecord * clrLog = dynamic_cast<CompensationLogRecord *> (log[i]);
        int lsn = clrLog->getLSN();
        int pageID = clrLog->getPageID();
        int reclsn = dirty_page_table[pageID];

        if(dirty_page_table.find(pageID) == dirty_page_table.end()){
          toRedo = false;
        }else if(reclsn > lsn){
          toRedo = false;
        }else{
          int pageLSN = se->getLSN(pageID);
          if(pageLSN >= lsn){
            toRedo = false;
          }
        }

        //redo
        if(toRedo){
          if(!se->pageWrite(pageID,clrLog->getOffset(),clrLog->getAfterImage(),lsn)){
            return false;
          }
        }
    }
  }

  // write end type record for C type
  map<int ,txTableEntry>::iterator tit;
  for(tit = tx_table.begin(); tit != tx_table.end(); tit++){
    if(tit->second.status == C){
      LogRecord* eLR = new LogRecord(se->nextLSN(),tit->second.lastLSN,tit->first,END);
      logtail.push_back(eLR);
      tx_table.erase(tit->first);
    }
  }

  return true;
}

/*
 * If no txnum is specified, run the undo phase of ARIES.
 * If a txnum is provided, abort that transaction.
 * Hint: the logic is very similar for these two tasks!
 */
void LogMgr::undo(vector <LogRecord*> log, int txnumc){
  // create the undo set
  priority_queue<int> ToUndo;
  //init the undoset from the tx_table
  if(txnumc == NULL_TX){
    map<int,txTableEntry>::iterator it;
    for(it = tx_table.begin(); it!=tx_table.end(); it++){
      if(it->second.status == U){
        ToUndo.push((it->second).lastLSN);
      }
    }
  }else{
    int mostRecentLSN_init = tx_table[txnumc].lastLSN;
    ToUndo.push(mostRecentLSN_init); 
  }

  while(!ToUndo.empty()){
    // find the largest
    int mostRecentLSN = ToUndo.top(); 
    for(int i = log.size()-1; i >= 0; i--){
      if(log[i]->getLSN() == mostRecentLSN){
        if(log[i]->getType() == UPDATE){
          UpdateLogRecord * updLog = dynamic_cast<UpdateLogRecord *> (log[i]);
          // a CLR log
          int cLSN = se->nextLSN();
          CompensationLogRecord * clr = 
              new CompensationLogRecord(cLSN,
                                          getLastLSN(updLog->getTxID()),
                                          updLog->getTxID(),
                                          updLog->getPageID(),
                                          updLog->getOffset(),
                                          updLog->getBeforeImage(),
                                          updLog->getprevLSN());
          logtail.push_back(clr);
          setLastLSN(updLog->getTxID(),cLSN);
          
          // abort or undo still makes the page dirty
          if(dirty_page_table.find(updLog->getPageID())==dirty_page_table.end()){
            dirty_page_table[updLog->getPageID()] = cLSN;
          }
            
          bool nbreak = se->pageWrite(updLog->getPageID(),updLog->getOffset(),
                          updLog->getBeforeImage(),cLSN);
          if(!nbreak){
            return;
          }

          if(updLog->getprevLSN() == NULL_LSN){
            // creating endlog
            int eLSN = se->nextLSN();
            LogRecord * endlog = new LogRecord(eLSN,getLastLSN(updLog->getTxID()),
                                             updLog->getTxID(),END);
            logtail.push_back(endlog);
            tx_table.erase(updLog->getTxID());
          }else{
              ToUndo.push(updLog->getprevLSN());
          }
        }else if(log[i]->getType() == CLR){
          CompensationLogRecord * clrLog = dynamic_cast<CompensationLogRecord *> (log[i]);
          if(clrLog->getUndoNextLSN() != NULL_LSN){
            ToUndo.push(clrLog->getUndoNextLSN());
          }else{
            int eLSN = se->nextLSN();
            LogRecord * endlog = new LogRecord(eLSN,getLastLSN(clrLog->getTxID()),
                                                clrLog->getTxID(),END);
            logtail.push_back(endlog);
            tx_table.erase(clrLog->getTxID());
          }
        }else{
          if(log[i]->getType() == ABORT){
            ToUndo.push(log[i]->getprevLSN());
          }
        }
        break;
      }
    }
    ToUndo.pop();
  }
}

vector<LogRecord*> LogMgr::stringToLRVector(string logstring){
  vector<LogRecord*> result;
  string line;
  istringstream lstream(logstring);
  while(getline(lstream, line)) {
    LogRecord* lr = LogRecord::stringToRecordPtr(line);
    result.push_back(lr);
  }
  return result;
}

/*
 * Abort the specified transaction.
 * Hint: you can use your undo function
 */
void LogMgr::abort(int txid){
  // abort log
  int abLSN = se->nextLSN();
  LogRecord * abLog = new LogRecord(abLSN,getLastLSN(txid),txid,ABORT);
  logtail.push_back(abLog);
  //modify trasaction table
  setLastLSN(txid,abLSN);

  // get the disklog
  string newLog = se->getLog();
  vector<LogRecord *> temp = stringToLRVector(newLog);

  // append with the logtail
  vector<LogRecord *> final;
  final.reserve(temp.size() + logtail.size());
  final.insert(final.end(),temp.begin(),temp.end());
  final.insert(final.end(),logtail.begin(),logtail.end());

  //undo
  undo(final,txid);
}

/*
 * Write the begin checkpoint and end checkpoint
 */
void LogMgr::checkpoint(){
  // first write the begin checkpoint log
  int bckLSN = se->nextLSN();
  TxType bck = BEGIN_CKPT;
  LogRecord * bckRecord = new LogRecord(bckLSN,NULL_LSN,NULL_TX,bck);
  logtail.push_back(bckRecord);
  se->store_master(bckLSN);
  // write the end checkpoint to the log
  int eckLSN = se->nextLSN();
  ChkptLogRecord * eckRecord = new ChkptLogRecord(eckLSN,bckLSN,NULL_TX,tx_table,dirty_page_table);
  logtail.push_back(eckRecord);
  
  flushLogTail(eckLSN);  
}

/*
 * Commit the specified transaction.
 */
void LogMgr::commit(int txid){
  // write this log record to the logtail
  int nLSN = se->nextLSN();
  LogRecord * cRecord = new LogRecord(nLSN,getLastLSN(txid),txid,COMMIT);
  logtail.push_back(cRecord);
  // adding to the trasction table since other than the end
  txTableEntry txEntry(nLSN,C);
  tx_table[txid] = txEntry;
  // flash tail
  flushLogTail(nLSN);
  //write the end
  int eLSN = se->nextLSN();
  LogRecord * eRecord = new LogRecord(eLSN,getLastLSN(txid),txid,END);
  logtail.push_back(eRecord);
  // remove the tx
  tx_table.erase(txid);
}

/*
 * A function that StorageEngine will call when it's about to 
 * write a page to disk. 
 * Remember, you need to implement write-ahead logging
 */
void LogMgr::pageFlushed(int page_id){
  // first force all the update log with this page_id
  // to the disk;
  flushLogTail(se->getLSN(page_id));
  // after push the page to the disk
  // remove the page from the dirty table
  if(dirty_page_table.find(page_id)!=dirty_page_table.end()){
    dirty_page_table.erase(page_id);
  }
}

/*
 * Recover from a crash, given the log from the disk.
 */
void LogMgr::recover(string log){
  //convert to the LogRecord*
  vector<LogRecord*> res = stringToLRVector(log);
  analyze(res);
  if(redo(res)){
    undo(res);
  }else{
    return;
  }
}

/*
 * Logs an update to the database and updates tables if needed.
 */
int LogMgr::write(int txid, int page_id, int offset, string input, string oldtext){
  int pageLSN = se->nextLSN();
  UpdateLogRecord* neWrt =  
    new UpdateLogRecord(pageLSN, getLastLSN(txid),txid,page_id,offset,oldtext,input);
  // adding to the logtail
  logtail.push_back(neWrt);
  // update the table
  setLastLSN(txid,pageLSN);

  // update the dirtypage table 
  if(dirty_page_table.find(page_id) == dirty_page_table.end()){
    dirty_page_table[page_id] = pageLSN;
  }
  return pageLSN;
}

/*
 * Sets this.se to engine. 
 */
void LogMgr::setStorageEngine(StorageEngine* engine){
  this->se = engine;
}