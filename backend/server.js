const express = require('express');
const cors = require('cors');
const dotenv = require('dotenv');

// Load environment variables
dotenv.config();

const app = express();
app.use(cors());
app.use(express.json());

const PORT = process.env.PORT || 3000;
const GEMINI_API_KEY = process.env.GEMINI_API_KEY || '';

// POST api/generate endpoint to proxy to Gemini
app.post('/api/generate', async (req, res) => {
  const { conversationHistory, systemInstruction } = req.body;

  if (!GEMINI_API_KEY) {
    console.error("Server GEMINI_API_KEY is not set in environment!");
    return res.status(500).json({ error: "Gemini API key is not configured on the server. Please add GEMINI_API_KEY to your .env file." });
  }

  if (!conversationHistory) {
    return res.status(400).json({ error: "Missing conversationHistory in request body." });
  }

  // Iterate over API versions and models to find a working Gemini configuration
  const apiVersions = ['v1beta', 'v1'];
  const models = ['gemini-flash-latest', 'gemini-3.5-flash', 'gemini-3.1-pro', 'gemini-3.1-flash-lite'];
  let lastError = null;

  for (const apiVersion of apiVersions) {
    for (const model of models) {
      const url = `https://generativelanguage.googleapis.com/${apiVersion}/models/${model}:generateContent`;
      
      // Format payload for Gemini API
      const contents = conversationHistory.map(msg => {
        const isUser = msg.isUser;
        const text = msg.text;
        return {
          role: isUser ? 'user' : 'model',
          parts: [
            { text: text }
          ]
        };
      });

      const body = {
        contents: contents,
        system_instruction: systemInstruction ? {
          parts: [
            { text: systemInstruction }
          ]
        } : undefined,
        generationConfig: {
          temperature: 0.7,
          maxOutputTokens: 2048
        }
      };

      try {
        console.log(`Forwarding request to Gemini API using version: ${apiVersion}, model: ${model}...`);
        const response = await fetch(url, {
          method: 'POST',
          headers: { 
            'Content-Type': 'application/json',
            'x-goog-api-key': GEMINI_API_KEY
          },
          body: JSON.stringify(body)
        });

        if (response.ok) {
          const data = await response.json();
          const candidates = data.candidates;
          if (candidates && candidates.length > 0) {
            const parts = candidates[0].content?.parts;
            if (parts && parts.length > 0) {
              const textResponse = parts[0].text;
              console.log(`Gemini response success using version: ${apiVersion}, model: ${model}`);
              console.log("Raw Gemini Text Response:\n", textResponse);
              return res.json({ text: textResponse });
            }
          }
          throw new Error("Empty candidate list or invalid format from Gemini API");
        } else {
          const errText = await response.text();
          console.warn(`Gemini version ${apiVersion}, model ${model} returned error status ${response.status}: ${errText}`);
          lastError = new Error(`Status ${response.status}: ${errText}`);
        }
      } catch (e) {
        console.error(`Gemini Service Exception for version ${apiVersion}, model ${model}: ${e.message}`);
        lastError = e;
      }
    }
  }

  return res.status(502).json({ error: "Failed to communicate with Gemini API across all models.", details: lastError?.message });
});

// Alias endpoint for flexibility
app.post('/api/chat', async (req, res) => {
  const { conversationHistory, systemInstruction } = req.body;
  if (!GEMINI_API_KEY) {
    return res.status(500).json({ error: "Gemini API key is not configured on the server." });
  }

  const apiVersions = ['v1beta', 'v1'];
  const models = ['gemini-flash-latest', 'gemini-3.5-flash', 'gemini-3.1-pro', 'gemini-3.1-flash-lite'];
  let lastError = null;

  for (const apiVersion of apiVersions) {
    for (const model of models) {
      const url = `https://generativelanguage.googleapis.com/${apiVersion}/models/${model}:generateContent`;
      const contents = conversationHistory.map(msg => ({
        role: msg.isUser ? 'user' : 'model',
        parts: [{ text: msg.text }]
      }));

      const body = {
        contents,
        system_instruction: systemInstruction ? { parts: [{ text: systemInstruction }] } : undefined,
        generationConfig: { temperature: 0.7, maxOutputTokens: 1024 }
      };

      try {
        const response = await fetch(url, {
          method: 'POST',
          headers: { 
            'Content-Type': 'application/json',
            'x-goog-api-key': GEMINI_API_KEY
          },
          body: JSON.stringify(body)
        });
        if (response.ok) {
          const data = await response.json();
          const textResponse = data.candidates?.[0]?.content?.parts?.[0]?.text;
          if (textResponse) return res.json({ text: textResponse });
        }
      } catch (e) {
        lastError = e;
      }
    }
  }
  return res.status(502).json({ error: "Failed to communicate with Gemini API.", details: lastError?.message });
});

// Verified Lesson Cache & Expert Verification Lifecycles
const verifiedLessonsCache = {};

app.get('/api/verified-lessons/:key', (req, res) => {
  const { key } = req.params;
  const cached = verifiedLessonsCache[key];
  if (cached) {
    console.log(`Cache HIT for key: ${key}`);
    return res.json(cached);
  }
  console.log(`Cache MISS for key: ${key}`);
  return res.status(404).json({ error: "Lesson not cached" });
});

app.post('/api/verified-lessons', (req, res) => {
  const { key, lesson } = req.body;
  if (!key || !lesson) {
    return res.status(400).json({ error: "Missing key or lesson payload" });
  }
  lesson.lifecycleStatus = 'AI_CHECKED';
  verifiedLessonsCache[key] = lesson;
  console.log(`Cached lesson for key: ${key} (Status: AI_CHECKED)`);
  return res.json({ success: true, status: 'AI_CHECKED' });
});

app.get('/api/verified-lessons', (req, res) => {
  return res.json(Object.keys(verifiedLessonsCache).map(key => ({
    key: key,
    lesson: verifiedLessonsCache[key],
    status: verifiedLessonsCache[key].lifecycleStatus || 'AI_CREATED'
  })));
});

app.post('/api/verified-lessons/review', (req, res) => {
  const { key, correctedKannadaText, status } = req.body;
  const cached = verifiedLessonsCache[key];
  if (!cached) {
    return res.status(404).json({ error: "Lesson not found in cache" });
  }
  if (correctedKannadaText) {
    cached.title = correctedKannadaText;
  }
  cached.lifecycleStatus = status || 'HUMAN_VERIFIED';
  console.log(`Lesson key ${key} status updated to: ${cached.lifecycleStatus}`);
  return res.json({ success: true, status: cached.lifecycleStatus });
});

const fs = require('fs');
const path = require('path');
const PROGRESS_DB_FILE = path.join(__dirname, 'progress_database.json');

// Helper to read database
function readProgressDb() {
  try {
    if (fs.existsSync(PROGRESS_DB_FILE)) {
      const raw = fs.readFileSync(PROGRESS_DB_FILE, 'utf8');
      return JSON.parse(raw);
    }
  } catch (e) {
    console.error("Error reading progress DB:", e);
  }
  return {};
}

// Helper to write database
function writeProgressDb(data) {
  try {
    fs.writeFileSync(PROGRESS_DB_FILE, JSON.stringify(data, null, 2), 'utf8');
  } catch (e) {
    console.error("Error writing progress DB:", e);
  }
}

// GET progress for an email
app.get('/api/progress/:email', (req, res) => {
  const { email } = req.params;
  console.log(`Fetching progress for email: ${email}`);
  const db = readProgressDb();
  const record = db[email.toLowerCase().trim()];
  if (record) {
    return res.json(record);
  }
  return res.status(404).json({ error: "Progress not found" });
});

// POST save progress for an email
app.post('/api/progress', (req, res) => {
  const { email, progress } = req.body;
  if (!email || !progress) {
    return res.status(400).json({ error: "Missing email or progress data" });
  }
  console.log(`Saving progress for email: ${email}`);
  const db = readProgressDb();
  db[email.toLowerCase().trim()] = progress;
  writeProgressDb(db);
  return res.json({ success: true });
});

// Health check endpoint for diagnostic connection testing
app.get('/api/health', (req, res) => {
  return res.json({ status: 'healthy', apiConnected: !!GEMINI_API_KEY });
});

// Subscription verification endpoint (Backend premium checks)
app.post('/api/verify-subscription', (req, res) => {
  const { userId, subscriptionToken } = req.body;
  if (subscriptionToken && subscriptionToken.startsWith('tok_sub_active')) {
    console.log(`Subscription verified for user: ${userId}`);
    return res.json({ isPremium: true });
  }
  console.log(`Subscription verification failed for user: ${userId}`);
  return res.json({ isPremium: false });
});

app.listen(PORT, () => {
  console.log(`Anedu Gemini Proxy Server running on port ${PORT}`);
  if (!GEMINI_API_KEY) {
    console.warn("WARNING: GEMINI_API_KEY environment variable is not defined. Set it in .env file to enable requests.");
  } else {
    console.log("Gemini API key loaded successfully.");
  }
});
