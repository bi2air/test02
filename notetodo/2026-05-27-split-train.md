# Clean data
 ok. let clean some label today. we have all payment data in @"experiments/split_train_may27/Affirm_call_log_changes_combined_upto_endof_May21st - all_payments_final_may27.csv". first we want to    
  clean data:                                                                                                                                                                                          
  1. rename Collin_Call_Id --> conv_id                                                                                                                                                                 
  2. rename Collin_Formatted_Transcript --> transcript                                                                                                                                                 
  3. Collin_Full_Transcript --> messages (keep the same format, it has the timestamp, and richer information)                                                                                          
  4. aff_CallType --> call_direction                                                                                                                                                                   
  5. aff_WrapUpCode --> callcode                                                                                                                                                                       
  for 5. We need further clean up, for example with conv_id: IET_3kq4PU_J4z3emgpXAA, PBP is callcode, we can add another columns codename: Pay By Phone and reasoning: ✗ correct_code: HPP - PBP       
  labeled but payment scheduled May 29 on call date May 23 - future date = HPP                                                                                                             also dedup if there duplication on conv_ids, after that save as "aff_clean_payments.csv"   


