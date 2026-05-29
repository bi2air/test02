ok. we need to run experiment to step-wise check what could have go wrong with IDV --> HUA.
  datasource: the Affirm_postcall_backfill_0805_2205_2026 - before_after_backfill.csv
  1. Select 10 samples that have IDV unchanged before and after refill
  2. Select 10 samples that have IDV changed to HUA
  3. Make sure these 20 samples have `list_current_state`, `dict_variable`/ `conversation_caching` in datadog or monitor/callcode
  run experiment:
  1. 20 samples without list_current_state
  2. 20 samples with list_current_state
  3. filter that 20 samples from this table: prj-ts-p-datascience-bdfc.ds_thanhvo_us.Affirm_backfill_0522, select after before and after transcript
  the experiment 3 can be pause until 1 and 2 done. let go.