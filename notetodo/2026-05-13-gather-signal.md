# Objective
- align with OKRs Q2, build a collection of sample test per call code 
- aim for 5 samples per level (l1: happy path, l2: co-operative with confusing wordings, filter words)
- aim for two clients, Kompato (RF/DTMF) is sufficient in raw number of samples, but have some call codes under represent

# Looking for signal
- our source of data in datadog, either pulled locally or directly pull from the datadog (if there is not existed locally, missing a piece of information) <-- what is tool and filter parameter to query such as data
- for this project, we will prioritze signal from customer, also refered as debtor, user or call receiver, caller, the distintion of each level is phone-level (call receiver -- outbound, caller --inbound), passed IDV (Id verification check) is become account level which is a customer. A debtor is one type of customer. The customer may be the third party, legal representatives, guardiance -- not strictly as the debtor.
- the ground truth data is the conversation/ transcript and bias toward what the user actually said. The inquiry line of assisistant is relevant to critial to pair which what the piece of information/ context the user response to 
- the chronogical order: the later intent take over the ealier one as this is clear example why root -> trunk -> leaf will be a good structure here.
- explicit over implicit: that why we have two codes, we do forensic of the conversation agaist principle of call code definitions. Implicit and high value is needed, implicit and trivival topic is low risk to ignore. Certainly, explicit and high value signal/ statue protection (such as do not call, written communication only.. ) -- we have list of items in kai_*/compliance_review

# What data we have so far
- 9GB of raw pulls from data dog at /datadog/hybrid_30d_202060511
- status of each tenats 
- our call code and prompt: the call code are the signals we are interested or must capture for risk manager, the prompt are method we use for classifier. The git repo in agi-sm-dsci-configs/scripts/**/main.yaml is the production version that generate the the datadog logs. The `origin/dev` are where we allowed to merge PR and the `origin/main` are the script are deployed in product. The tenant can be `Affirm` or `DTMF` for RF (Republic Finance)
- We are working on OKRs, we can tell that generating sample test can be difficult; the most challenging aspect will be matching our desired signal vs the actual user|debtor utterance - for that we take the our actual log, detect signal and map back to conversation

# How to proceed
- here is my plan, feel free to crique and make it better
- check the list of call codes, and reasoning of each conversation (given a tenant) --> this is our signals from the current classifier 
- go back to the conversation, doing forensic to capture each call code in list_call_codes
- check if the singal is L1 (happy path, single intent) or L2/ L3 (we have an agi-9466 pipeline with Kom adverserial simulation)

# Output
- what is output look like
- for each tenant (start with RF/DTMF first as this has more material to work with) -- Affirm will be next (they are our premium customer)
- for each call code we will have conversation, slide the conversation history from the beginning to that the intent for that call code,
- and a tag for a level
- we may need to recheck the confidence score to see if the evidence is strong to support our signal

