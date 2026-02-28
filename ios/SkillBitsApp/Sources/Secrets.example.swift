// Copy this file to Secrets.swift and fill in your values.
// Secrets.swift is gitignored.
enum Secrets {
    // Local: "http://127.0.0.1:54321"
    // Cloud: "https://YOUR_PROJECT.supabase.co"
    static let supabaseURL = "http://127.0.0.1:54321"

    // Local default anon key (from `supabase start` output)
    // Cloud: grab from Supabase Dashboard > Settings > API
    static let supabaseAnonKey = "YOUR_PUBLISHABLE_KEY"
}
