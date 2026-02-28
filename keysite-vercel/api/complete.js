const supabase = require('./_supabase');
const crypto = require('crypto');

function generateKey() {
  const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
  const seg = () => Array.from({ length: 4 }, () => chars[Math.floor(Math.random() * chars.length)]).join('');
  return `${seg()}-${seg()}-${seg()}-${seg()}`;
}

module.exports = async (req, res) => {
  res.setHeader('Access-Control-Allow-Origin', '*');

  const { token } = req.query;
  const ip = req.headers['x-forwarded-for']?.split(',')[0] || req.socket.remoteAddress;

  if (!token) return res.json({ success: false, error: 'Missing token' });

  // Vérifie le token
  const { data: pending, error } = await supabase
    .from('pending_tokens')
    .select('*')
    .eq('token', token)
    .eq('ip', ip)
    .gt('expires_at', new Date().toISOString())
    .single();

  if (error || !pending) {
    return res.json({ success: false, error: 'Invalid or expired token. Please start over.' });
  }

  // Supprime le token pour qu'il ne soit plus réutilisable
  await supabase.from('pending_tokens').delete().eq('token', token);

  // Génère une key unique
  let newKey;
  let exists = true;
  while (exists) {
    newKey = generateKey();
    const { data } = await supabase.from('keys').select('id').eq('key_value', newKey).single();
    exists = !!data;
  }

  const expiresAt = new Date(Date.now() + 24 * 60 * 60 * 1000).toISOString(); // 24h

  await supabase.from('keys').insert({
    key_value: newKey,
    ip,
    created_at: new Date().toISOString(),
    expires_at: expiresAt
  });

  res.json({ success: true, key: newKey, expires_at: expiresAt });
};
