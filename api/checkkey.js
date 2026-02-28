const supabase = require('./_supabase');

module.exports = async (req, res) => {
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Content-Type', 'application/json');

  const { key, hwid } = req.query;

  if (!key) return res.json({ valid: false, message: 'No key provided' });

  const { data: row } = await supabase
    .from('keys')
    .select('*')
    .eq('key_value', key)
    .single();

  if (!row) return res.json({ valid: false, message: 'Invalid key' });

  if (new Date(row.expires_at) < new Date()) {
    return res.json({ valid: false, message: 'Key expired' });
  }

  // Bind HWID au premier usage
  if (hwid) {
    if (!row.hwid) {
      await supabase.from('keys').update({ hwid }).eq('key_value', key);
    } else if (row.hwid !== hwid) {
      return res.json({ valid: false, message: 'HWID mismatch' });
    }
  }

  const hoursLeft = ((new Date(row.expires_at) - new Date()) / 3600000).toFixed(1);

  return res.json({
    valid: true,
    message: 'KEY_VALID',
    key_valid: true,
    hours_left: hoursLeft,
    expires_at: row.expires_at
  });
};
