from strands import Agent
from .tools import ALL_TOOLS

agent = Agent(tools=ALL_TOOLS)

if __name__ == "__main__":
    response = agent("What is the current date and calculate sqrt(144)")
    print(response)
