from crewai import Agent, Task, Crew
from .tools import ALL_TOOLS

researcher = Agent(
    role="Research Assistant",
    goal="Answer factual questions accurately",
    backstory="You are an expert researcher that uses tools.",
    tools=ALL_TOOLS,
    verbose=True,
    allow_delegation=False
)

task = Task(
    description="What is the current date and calculate 17 * 83.",
    expected_output="A brief response with the date and math result.",
    agent=researcher
)

crew = Crew(
    agents=[researcher],
    tasks=[task],
    verbose=True
)

if __name__ == "__main__":
    result = crew.kickoff()
    print("Crew output:")
    print(result)
