-- Add audio_url column to lessons for pre-generated ElevenLabs audio
ALTER TABLE lessons ADD COLUMN audio_url text;
