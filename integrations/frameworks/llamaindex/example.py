from llama_index.core.agent import FunctionCallingAgent
from llama_index.llms.openai import OpenAI
from .tools import ALL_TOOLS

llm = OpenAI(model="gpt-4o")
agent = FunctionCallingAgent.from_tools(
    tools=ALL_TOOLS,
    llm=llm,
    verbose=True,
    system_prompt="Always use tools for date, math, randomness, and UUIDs."
)
response = agent.chat("What is today's date and generate a UUID for me?")
print(response)
