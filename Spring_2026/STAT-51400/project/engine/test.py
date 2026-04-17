import argparse
import pandas as pd
from itertools import product
import sys
# Assuming model.py is in the same directory
from model import ChatModel

def main():
    # --- Argument Parsing ---
    parser = argparse.ArgumentParser(description="Run LLM tests based on CSV parameters.")
    parser.add_argument("--models_path", required=True, help="Path to CSV containing 'models' column")
    parser.add_argument("--temps_path", required=True, help="Path to CSV containing 'temperatures' column")
    parser.add_argument("--efforts_path", required=True, help="Path to CSV containing 'effort' column")
    args = parser.parse_args()

    # --- Load Data ---
    try:
        df_models = pd.read_csv(args.models_path)
        df_temps = pd.read_csv(args.temps_path)
        df_efforts = pd.read_csv(args.efforts_path)
    except FileNotFoundError as e:
        print(f"Error: Could not find CSV file {e.filename}")
        return

    # --- Extract Columns ---
    # Ensure we are grabbing the column names exactly as specified
    models_list = df_models['models'].tolist()
    temps_list = df_temps['temperatures'].tolist()
    efforts_list = df_efforts['effort'].tolist()

    print(f"Found {len(models_list)} models, {len(temps_list)} temps, {len(efforts_list)} efforts.")
    print("Starting tests...\n")

    # --- Loop through Combinations ---
    for model_name, temperature, effort in product(models_list, temps_list, efforts_list):

        # Initialize Model
        chatbot = ChatModel(model_name, temperature=temperature, effort=effort)

        # Perform Test (PoC: Asking for a short response)
        user_prompt = "Say 'Hello' in exactly 3 words."

        print(f"--- Testing: Model={model_name}, Temp={temperature}, Effort={effort} ---")
        response = chatbot.chat(user_prompt)
        print(f"Response: {response}")
        print("-" * 40)

if __name__ == "__main__":
    main()