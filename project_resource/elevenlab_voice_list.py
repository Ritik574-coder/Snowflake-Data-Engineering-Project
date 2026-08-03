from elevenlabs.client import ElevenLabs
from dotenv import load_dotenv
import os

load_dotenv()

client = ElevenLabs(
    api_key=os.getenv("ELEVENLAB_API")
)

voices = client.voices.get_all()

for voice in voices.voices:
    print("=" * 50)
    print("Name     :", voice.name)
    print("Voice ID :", voice.voice_id)