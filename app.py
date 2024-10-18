import os
from dotenv import load_dotenv
from jinja2 import Environment, FileSystemLoader

# Load environment variables
load_dotenv()
os.environ["OPENAI_API_KEY"] = os.getenv("OPENAI_API_KEY")

from langchain_openai import ChatOpenAI
from langchain_core.output_parsers import StrOutputParser
from langchain_core.prompts import ChatPromptTemplate

# Initialize model
model = ChatOpenAI(model="gpt-4o")





# Setup Jinja2 template rendering

env = Environment(loader=FileSystemLoader('./prompts'))
template = env.get_template('joke.j2')

# Render the template with a topic
rendered_prompt = template.render(topic="ice cream")

# Use the rendered prompt in the chain
prompt = ChatPromptTemplate.from_template(rendered_prompt)
output_parser = StrOutputParser()
chain = prompt | model | output_parser

# Invoke the chain with the rendered template
print(chain.invoke({}))
