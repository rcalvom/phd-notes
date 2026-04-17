"""Entry point file"""

# Utils
#from dotenv import load_dotenv
import argparse

# Engine


def main():
    """Main function"""
    parser = argparse.ArgumentParser(description="LLM Statistical Experiments")
    parser.add_argument("--model", type=str, required=True, help="Model name to use in the experiment")
    parser.add_argument("--effort", type=str, choices=["low", "medium", "high"], required=True, help="Effort level: low, medium or high")
    parser.add_argument("--temperature", type=float, required=True, help="Temperature value between 0 and 1")

    args = parser.parse_args()

    print("--- Experiment Configuration ---")
    print(f"Model: {args.model}")
    print(f"Effort: {args.effort}")
    print(f"Temperature: {args.temperature}")
    print("----------------------")

if __name__ == "__main__":
    # load_dotenv()
    main()