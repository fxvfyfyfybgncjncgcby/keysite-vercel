const supabase = require('./_supabase');
const crypto = require('crypto');

module.exports = async (req, res) => {
  res.setHeader('Access-Control-Allow-Origin', '*');

  const ip = req.headers['x-forwarded-for']?.split(',')[0] || req.socket.remoteAddress;

  // Vérifie si IP a déjà une key valide
  const { data: existing } = await supabase
    .from('keys')
    .select('key_value, expires_at')
    .eq('ip', ip)
    .gt('expires_at', new Date().toISOString())
    .order('created_at', { ascending: false })
    .limit(1)
    .single();

  if (existing) {
    return res.json({ hasKey: true, key: existing.key_value, expires_at: existing.expires_at });
  }

  // Génère un token unique pour cet utilisateur
  const token = crypto.randomBytes(32).toString('hex');

  // Supprime les anciens tokens de cet IP
  await supabase.from('pending_tokens').delete().eq('ip', ip);

  // Insère le nouveau token
  await supabase.from('pending_tokens').insert({
    token,
    ip,
    created_at: new Date().toISOString(),
    expires_at: new Date(Date.now() + 2 * 60 * 60 * 1000).toISOString() // 2h
  });

  // Génère le lien Linkvertise
  const siteUrl = process.env.SITE_URL;
  const callbackUrl = `${siteUrl}/complete?token=${token}`;
  const linkvertiseUserId = process.env.LINKVERTISE_USER_ID;
  const encodedUrl = Buffer.from(callbackUrl).toString('base64');
  const linkvertiseUrl = `https://linkvertise.com/${linkvertiseUserId}/getkey?o=sharing&r=${encodeURIComponent(encodedUrl)}`;

  res.json({ hasKey: false, linkvertiseUrl, token });
};
