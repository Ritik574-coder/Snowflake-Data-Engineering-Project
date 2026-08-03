from moviepy.editor import ImageClip, AudioFileClip

IMAGE_PATH = "/content/snowflake_poster.png"
AUDIO_PATH = "/content/snowflake_project_intro.mp3"
OUTPUT_PATH = "snowproject_demo_video.mp4"

# Load audio
audio = AudioFileClip(AUDIO_PATH)

# Image ko audio duration tak video bana do
video = (
    ImageClip(IMAGE_PATH, duration=audio.duration)
    .set_audio(audio)
)

# Export MP4
video.write_videofile(
    OUTPUT_PATH,
    fps=24,
    codec="libx264",
    audio_codec="aac"
)

audio.close()
video.close()

print(f"Video created: {OUTPUT_PATH}")