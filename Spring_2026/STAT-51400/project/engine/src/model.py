import litellm

class ChatModel:
    def __init__(self, model_name, temperature=0.7, effort="Standard"):
        self.model_name = model_name
        self.temperature = temperature
        self.messages = [
            {
                "role": "system",
                "content": f"You are a helpful assistant. (Testing Effort Level: {effort})"
            }
        ]

    def chat(self, user_message):
        try:
            response = litellm.completion(
                model=self.model_name,
                messages=self.messages + [{"role": "user", "content": user_message}],
                temperature=self.temperature
            )
            return response.choices[0].message.content
        except Exception as e:
            return f"Error: {e}"

# Placeholder for the tool definition if you are using a tool,
# otherwise you can remove this block.
WEATHER_TOOL_SCHEMA = {
    "type": "object",
    "properties": {
        "location": {"type": "string"},
        "units": {"type": "string", "enum": ["celsius", "fahrenheit"]}
    },
    "required": ["location"]
}