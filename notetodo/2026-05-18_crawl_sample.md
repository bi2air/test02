# Context
- We have data collected real call data from datadog. The real call data is a collection we need to parse them and find specific sample for our call code development
- The data from datadog has distribution bias toward non-pick up call, call with short turn and calls to automated system (like voice mail, robot calll)

# How to think like a manual reviewer?
- What is the outbound or inbound call? What is sequence looking like in actual for someone who call you (inbound) or you call someone (outbound)?
-- Inbound call: usually you pick up, and said something like "Hello", "Alo", "this is ABC speak?"
-- Outboud cald: you call someone, you want for the signal to pick up with reponse like "yes", "hello"
- Transcript artifacts or runtime markup:
-- The transcript is produced via a Speech Recognition System, with contains added text for AI-powered voice system, for example <SILENCE_5s> to to let bot (assisant pause 5s)  --> while these are text, they dont' carry the same meaning as user is listenning in 5seconds OR or [company_name_Affirm] to let the voice synthesize the audio with a styled pronouciation
- Put in your hats as this example: output/affirm_signal_pilot_20260518_161246/codex_signal_review_3x5_escalated/summary.json, each role will have different style of doing forensic of call code (definition) agaist evicence (transcript) to draw a conclusion (final call code or list of potential call codes)

# How are we know that the sample is meeting standard and usable
1. if the sample can be fed to the callcode rereun and no missing requirement --> first pass
2. if the call code return one of call code that is closedly defined --> okay, but that is give a peace of mind
3. how many list_call_codes returns, for L1 that should be single intent so 1, and then L2, L3 with increasing complexity and thus possible more call codes or even predict neighboring call codes (like the 2.)
4. If call code rerun produce exact desired call code, that is a final pass


# How a sample is in a good format for manual review?
must have
- conversation_id
- tenant: for multiple or unspecified tenants, this must be presented
- predicted_callcode: this is intent or callcode we are looking for or desired to find one
- RCA: basic information, enough for the review
- call_direction: since we have inbound and outbound, there expectation on the first response and level of strictness to identify RPC, this must be explicit
- evidence of intent: a smallest but sufficient unit to be self-contained
- transcript: slicing or entired transcript: --> this will be used for the postcall rerun. Always check if the transcript starting the beginning
- render_prompt: for postcall classification, the google sheet may truncate, the file produced at local has to completed
- list_call_codes: this is all intent produced by the postcall classification 
- final callcode: may include ranking and postprocessing
- reasoning: reasoning produced by the classification 


# How to define a good sample for review
- Should provide enough context
-- What is the call code we are looking for? --> what are the definition of that call code
-- What is the evidence in the transcript justify for that intent? --> is the user' response is self-contained or it has be with assistant questions --> is one pair of turns sufficient
-- What are the transcript, start the beginning, to the evidence of intent? --> does this sliced transcript make a good sample
-- What is the confidence of sub-agents on this?

# How to make a testset:
must have:
- conversation_id
- tenant: explictly, unless we are working on solely on a tenant
- call direction
- label_callcode, choose one the with highest confidence. For example in sheet: https://docs.google.com/spreadsheets/d/1jwTsoz3jRuZ3AyxlDN9OgwHMw4v-6F91X8G27Ez5kTc/edit?gid=2111032479#gid=2111032479, we have opus and codex as, and final callcode. If they are consensus and high confident score with final callcode --> then it is a good label,
- level: this is judging from complexity of user response + transcript synopsis. This level grading should be available to use through out this session. 
- rca: that raw_call_assignment for example, if the local is not availble, we can query data and filter datadog data with event "Init conversation State machine" or filename "init_conversation" we should see `raw_call_assignment`. Bonus, when filter with "@func_name: 'process_call_analyzer'" with loggger_name: "celery_calculate_call_code", we will a rich payload, contains all information for the inputs for call code calculate
- history_reflection: , we can query datadog with "*:<conversation_id> @event:(sm_update_cache) " take the latest timestamp --> new_history_reflection
- list_current_state: something refer as "new_list_current_state" --> this is more univversal
