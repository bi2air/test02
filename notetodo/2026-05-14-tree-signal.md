# Context
- our call code classifiers while design to capture more than one call codes, it can be often bias toward to strongest signal and left out other minor but justifiable signal. 
- we want to gather all signals that deems relevant to our process, because depends on value and priority, the prevail signal may not be the most seeking signal. 
For example, the phone call with customer, the signal that the call receiver is a customer is prevail, but that is not informative, but if the customer asking something account or repay, even briefly before turning to they are busy and there is a meeting coming up. Then the economic/ collection value if a customer are looking/ interested/ curious about the debt is valuable. 

# My approach
- Think about the signal as the tree. You can see the v4 tree in kai_*/tree folder, and may check with the latest Kompato master call code for the update kai_*/Kompato_***_<timestamp>.csv (the most recent one is may12). 
- Start with root (phone holder, customer, not customer), for example
- For each line of inquiry, what are the assistant question, what are the response of the customer, how confidence are we in term of aligning the call code with the conversation so far. 
- The tree apporoach is benefit since the user (phone holder|debtor|customer) many have multi track during the phone call conversation, and trunk from the root can be close to each other, but not same. 
- We apply the MECE principle here, that we look at the top down from the conversation, what are major topics at the top level? The major topics are the call code or phase -- but at current task, we look at the call code
- For one trunk, there can be leaf level, or not there. Conversation can be complicated, and the customer signal is not always explicit. The customer saying is not clear, and nuance in meaning, there are noise from environment, inaccuracy from our Automatic Speech Transcripton to convert from audio to text, there can be hidden context, such as the customer in the supermarket talking to someone else and the transcript cannot distinguish, inpefect of the AI-powered voice assisisted system, when the turn is not clear and there cross-over between what the user|customer is saying then pause and what the assistant interrupted or fill in the pause. That why we have may have two call code to cover one path, one at the top level (high value) and one below it (high confidence)

# Input
- Conversation transcript in text 
- Prompt template to render to conversation and with instruction and output

# Output
- List of call codes to conver the tree
- reasonning: why the list of call codes appear that ways, why the current prompt/ experimental prompts differ.sx