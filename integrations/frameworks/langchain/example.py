from langchain_openai import ChatOpenAI
from langchain.agents import create_tool_calling_agent, AgentExecutor
from langchain_core.prompts import ChatPromptTemplate
from .tools import ALL_TOOLS

# Note: You can swap ChatOpenAI for ChatAnthropic or others
llm = ChatOpenAI(model="gpt-4o")
prompt = ChatPromptTemplate.from_messages([
    ("system", "You are a helpful assistant with tools."),
    ("user", "{input}"),
    ("placeholder", "{agent_scratchpad}"),
])
agent = create_tool_calling_agent(llm, ALL_TOOLS, prompt)
executor = AgentExecutor(agent=agent, tools=ALL_TOOLS)

if __name__ == "__main__":
    result = executor.invoke({"input": "What is today's date and what is 17 * 83?"})
    print(result["output"])
