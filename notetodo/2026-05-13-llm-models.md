# Context
- we want to maximize LLM model choice between smart vs cost vs availability
- our server (192.168.5.250, refer as "zero") are place to call LLM hub
- we can check the model offer by LiteLLM forward hub using this:
```
hub_client = llm_hub_client = openai.OpenAI(
        api_key=os.getenv("LLMHUB_MASTER_KEY"),
        base_url=os.getenv("LLMHUB_URL"),
    )
```

# For all models:
```
res = hub_client.models.list()
```
## Gemini:
```
models = [x.id for x in res.data if 'gemini' in x.id]
models
```
and so on for "claude" , "gpt-5" for other LLM providers

# How do we know which model is for what?
- here is one place to check it: `https://artificialanalysis.ai/`, you may need to you browser, or other place in Internet, mcp of similar information/ comparison existed. But this is good place to visit.

# Capture this information, store it
- A good practice is to capture this available models and what is good for. We will need this for our major-voters and classifier.

