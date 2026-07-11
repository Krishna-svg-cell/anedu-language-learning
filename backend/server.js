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
const API_SECRET_KEY = process.env.API_SECRET_KEY || 'AneduSecureAppHandshakeKey2026';

// Middleware to verify authorization handshake headers
function verifyAuth(req, res, next) {
  const clientKey = req.headers['x-anedu-auth'];
  if (!clientKey || clientKey !== API_SECRET_KEY) {
    console.warn(`Unauthorized request blocked from IP: ${req.ip}`);
    return res.status(401).json({ error: "Unauthorized access: Invalid or missing API handshake credentials." });
  }
  next();
}

// POST api/generate endpoint to proxy to Gemini
app.post('/api/generate', verifyAuth, async (req, res) => {
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
app.post('/api/chat', verifyAuth, async (req, res) => {
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

const path = require('path');
const sqlite3 = require('sqlite3').verbose();

const dbPath = path.join(__dirname, 'database.sqlite');
const db = new sqlite3.Database(dbPath, (err) => {
  if (err) {
    console.error("Failed to connect to SQLite database:", err);
  } else {
    console.log("Connected to SQLite persistent database:", dbPath);
    // Initialize database tables
    db.run(`
      CREATE TABLE IF NOT EXISTS user_progress (
        email TEXT PRIMARY KEY,
        progress_data TEXT NOT NULL,
        updated_at DATETIME DEFAULT CURRENT_TIMESTAMP
      )
    `, (tableErr) => {
      if (tableErr) console.error("Error creating user_progress table:", tableErr);
    });
  }
});

// GET progress for an email
app.get('/api/progress/:email', verifyAuth, (req, res) => {
  const { email } = req.params;
  const cleanEmail = email.toLowerCase().trim();
  console.log(`Fetching SQLite progress for email: ${cleanEmail}`);
  
  db.get('SELECT progress_data FROM user_progress WHERE email = ?', [cleanEmail], (err, row) => {
    if (err) {
      console.error("Database query error on progress fetch:", err);
      return res.status(500).json({ error: "Internal database query error." });
    }
    if (row) {
      try {
        const parsed = JSON.parse(row.progress_data);
        return res.json(parsed);
      } catch (parseErr) {
        console.error("JSON parsing error on row data:", parseErr);
        return res.status(500).json({ error: "Corrupted database record." });
      }
    }
    return res.status(404).json({ error: "Progress not found" });
  });
});

// POST save progress for an email
app.post('/api/progress', verifyAuth, (req, res) => {
  const { email, progress } = req.body;
  if (!email || !progress) {
    return res.status(400).json({ error: "Missing email or progress data" });
  }
  const cleanEmail = email.toLowerCase().trim();
  console.log(`Saving SQLite progress for email: ${cleanEmail}`);
  const dataString = JSON.stringify(progress);
  
  db.run(
    'INSERT INTO user_progress (email, progress_data, updated_at) VALUES (?, ?, CURRENT_TIMESTAMP) ON CONFLICT(email) DO UPDATE SET progress_data = excluded.progress_data, updated_at = CURRENT_TIMESTAMP',
    [cleanEmail, dataString],
    (err) => {
      if (err) {
        console.error("Database write error on progress save:", err);
        return res.status(500).json({ error: "Failed to write user progress to database." });
      }
      return res.json({ success: true });
    }
  );
});

// DELETE progress for an email (Compliance Guideline 5.1.1)
app.delete('/api/progress/:email', verifyAuth, (req, res) => {
  const { email } = req.params;
  const cleanEmail = email.toLowerCase().trim();
  console.log(`Deleting SQL progress for email: ${cleanEmail}`);
  
  db.run('DELETE FROM user_progress WHERE email = ?', [cleanEmail], function(err) {
    if (err) {
      console.error("Database write error on progress delete:", err);
      return res.status(500).json({ error: "Failed to remove database record." });
    }
    return res.json({ success: true, deleted: this.changes > 0 });
  });
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
