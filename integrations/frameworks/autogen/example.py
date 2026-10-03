import asyncio
from autogen_agentchat.agents import AssistantAgent
from autogen_agentchat.ui import Console
from autogen_agentchat.conditions import TextMentionTermination
from autogen_agentchat.teams import RoundRobinGroupChat
from autogen_ext.models.openai import OpenAIChatCompletionClient
from .tools import ALL_TOOLS

async def main():
    model_client = OpenAIChatCompletionClient(model="gpt-4o")
    agent = AssistantAgent(
        name="assistant",
        model_client=model_client,
        tools=ALL_TOOLS,
        system_message="You are a helpful assistant. Always use tools for date, math, and randomness."
    )
    termination = TextMentionTermination("TERMINATE")
    team = RoundRobinGroupChat([agent], termination_condition=termination)
    await Console(team.run_stream(task="What is today's date and what is 17 * 83?"))

asyncio.run(main())
