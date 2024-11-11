from openai import OpenAI
from datetime import datetime
from pathlib import Path
import os, sys


def add_example(n, path):
    prompt = f"Example {n}:\n\n```\n"
    with open(path, "r", encoding="utf-8", errors="ignore") as f:
        prompt += f.read()

    prompt += "\n```\n\n"
    return prompt


def read_file(path):
    text = "```\n"
    with open(path, "r", encoding="utf-8", errors="ignore") as f:
        text += f.read()

    text += "\n```\n\n"
    return text


def make_prompt(examples):
    prompt = "For the PDF format, the following is the dictionary for the format:\n\n"
    prompt += read_file(os.path.dirname(__file__) + "/pdf_fuzzer.dict")

    prompt += "And the following are examples of files:\n\n"

    for i, ex in enumerate(examples):
        prompt += add_example(i, ex)

    prompt += "Please enrich the PDF files corpus with the other files of the PDF format that contain text, different fonts and images. And the other examples of PDF files are:\n\n"

    return prompt


def extract_pdfs(response, path):
    lines = response.split("\n")
    i = 0
    seeds = 0
    while i < len(lines):
        if lines[i] == "```":
            pdf_lines = []
            i += 1
            while i < len(lines) and not lines[i] == "```":
                pdf_lines.append(lines[i])
                i += 1
            datetime_string = datetime.now().strftime("%Y%m%d_%H%M%S")
            i += 1

            with open(
                Path(path) / f"seed_{datetime_string}_{i}.pdf",
                "w",
                encoding="utf-8",
                errors="ignore",
            ) as f:
                f.write("\n".join(pdf_lines))
            seeds += 1
        else:
            i += 1
    return seeds


client = OpenAI(
    api_key=os.getenv("ISP_LLM_API_KEY"),  # ваш ключ в сервисе после регистрации
    base_url=os.getenv("ISP_LLM_API_URL"), # адрес сервиса OpenAI
)

files = []
for file in Path("corpus").glob("*.pdf"):
    files.append(file)
examples = [files[0]]
prompt = make_prompt(examples)
print(prompt)

messages = []
# messages.append({"role": "system", "content": system_text})
messages.append({"role": "user", "content": prompt})

response_big = client.chat.completions.create(
    model="anthropic/claude-3-haiku",  # id модели из списка моделей - можно использовать OpenAI, Anthropic и пр. меняя только этот параметр
    messages=messages,
    temperature=0.7,
    n=5,
    max_tokens=3000,  # максимальное число ВЫХОДНЫХ токенов. Для большинства моделей не должно превышать 4096
    extra_headers={
        "X-Title": "My App"
    },  # опционально - передача информация об источнике API-вызова
)

seeds = 0
# print("Response BIG:",response_big)
for resp in response_big.choices:
    print(resp.message.content)
    response = resp.message.content
    print("Response:", response)

    seeds += extract_pdfs(response, "new_seeds")

f_i = 0
while seeds < 10:
    f_i = min(f_i, len(files) - 2)
    examples = [files[f_i + 1]]
    f_i += 1
    prompt = make_prompt(examples)
    print(prompt)

    messages = []
    # messages.append({"role": "system", "content": system_text})
    messages.append({"role": "user", "content": prompt})
    response_big = client.chat.completions.create(
        model="anthropic/claude-3-haiku",  # id модели из списка моделей - можно использовать OpenAI, Anthropic и пр. меняя только этот параметр
        messages=messages,
        temperature=0.7,
        n=5,
        max_tokens=3000,  # максимальное число ВЫХОДНЫХ токенов. Для большинства моделей не должно превышать 4096
        extra_headers={
            "X-Title": "My App"
        },  # опционально - передача информация об источнике API-вызова
    )
    for resp in response_big.choices:
        print(resp.message.content)
        response = resp.message.content
        print("Response:", response)

        seeds += extract_pdfs(response, "new_seeds")
