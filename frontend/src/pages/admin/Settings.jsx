import { useEffect, useState } from 'react';
import { adminAPI } from '../../services/api';

const FIELDS = [
  { key: 'hotline_phone', label: 'Emergency Hotline', icon: 'bi-telephone-fill', group: 'Contact', hint: 'Shown on the landing Emergency section. Leave empty to hide the call button.' },
  { key: 'support_phone', label: 'Support Phone', icon: 'bi-telephone', group: 'Contact', hint: 'Shown in the footer (tel: link).' },
  { key: 'support_email', label: 'Support Email', icon: 'bi-envelope-fill', group: 'Contact', hint: 'Shown in the footer (mailto: link).' },
  { key: 'address', label: 'Address', icon: 'bi-geo-alt-fill', group: 'Contact' },
  { key: 'working_hours', label: 'Working Hours', icon: 'bi-clock-fill', group: 'Contact' },
  { key: 'response_time_text', label: 'Response Time Text', icon: 'bi-lightning-fill', group: 'Contact', hint: 'E.g. "Less than 1 hour". Free text — only show what you can actually deliver.' },
  { key: 'facebook_url', label: 'Facebook URL', icon: 'bi-facebook', group: 'Social', hint: 'Leave empty to hide the icon from the footer.' },
  { key: 'twitter_url', label: 'Twitter / X URL', icon: 'bi-twitter', group: 'Social' },
  { key: 'instagram_url', label: 'Instagram URL', icon: 'bi-instagram', group: 'Social' },
  { key: 'linkedin_url', label: 'LinkedIn URL', icon: 'bi-linkedin', group: 'Social' },
  { key: 'app_store_url', label: 'App Store URL', icon: 'bi-apple', group: 'Stores', hint: 'Links the "App Store" buttons. Leave empty to disable them.' },
  { key: 'play_store_url', label: 'Google Play URL', icon: 'bi-google-play', group: 'Stores' },
];

const GROUPS = ['Contact', 'Social', 'Stores'];

const Settings = () => {
  const [form, setForm] = useState({});
  const [loading, setLoading] = useState(true);
  const [saving, setSaving] = useState(false);
  const [message, setMessage] = useState(null);

  useEffect(() => {
    let cancelled = false;
    adminAPI.siteConfig
      .get()
      .then((res) => {
        if (!cancelled) setForm(res.data || {});
      })
      .catch(() => {
        if (!cancelled) setMessage({ type: 'danger', text: 'Failed to load site settings.' });
      })
      .finally(() => {
        if (!cancelled) setLoading(false);
      });
    return () => {
      cancelled = true;
    };
  }, []);

  const handleChange = (e) => {
    setForm((prev) => ({ ...prev, [e.target.name]: e.target.value }));
  };

  const handleSave = () => {
    setSaving(true);
    setMessage(null);
    adminAPI.siteConfig
      .update(form)
      .then((res) => {
        setForm(res.data || form);
        setMessage({ type: 'success', text: 'Settings saved. The landing page will pick them up within a few seconds.' });
      })
      .catch((err) => {
        const detail =
          typeof err?.response?.data === 'string'
            ? err.response.data
            : err?.response?.data?.non_field_errors?.join(', ') ||
              err?.response?.data?.detail ||
              'Failed to save settings.';
        setMessage({ type: 'danger', text: detail });
      })
      .finally(() => setSaving(false));
  };

  if (loading) {
    return (
      <div className="d-flex justify-content-center py-5">
        <div className="spinner-border text-primary" role="status" />
      </div>
    );
  }

  return (
    <div>
      <div className="page-header d-flex justify-content-between align-items-start flex-wrap gap-2">
        <div>
          <h4 className="mb-1">Site Settings</h4>
          <p className="mb-0">
            Contact info, social links and app-store URLs shown on the landing page. Empty fields are hidden, not faked.
          </p>
        </div>
        <button
          type="button"
          className="btn btn-primary px-4"
          onClick={handleSave}
          disabled={saving}
          style={{ background: '#6366f1', borderColor: '#6366f1' }}
        >
          {saving ? (
            <>
              <span className="spinner-border spinner-border-sm me-2" role="status" /> Saving…
            </>
          ) : (
            <>
              <i className="bi bi-check-lg me-2" /> Save Settings
            </>
          )}
        </button>
      </div>

      {message && (
        <div className={`alert alert-${message.type} mt-3 mb-0`} role="alert">
          {message.text}
        </div>
      )}

      {GROUPS.map((group) => (
        <div key={group} className="card border-0 shadow-sm mt-4" style={{ borderRadius: '12px' }}>
          <div className="card-header bg-white border-0 pb-0 pt-3">
            <h6 className="fw-bold mb-0" style={{ color: '#0f172a' }}>{group}</h6>
          </div>
          <div className="card-body">
            <div className="row g-3">
              {FIELDS.filter((f) => f.group === group).map((f) => (
                <div key={f.key} className="col-md-6">
                  <label className="form-label small fw-semibold" htmlFor={`settings-${f.key}`}>
                    {f.label}
                  </label>
                  <div className="input-group">
                    <span className="input-group-text">
                      <i className={`bi ${f.icon}`} style={{ fontSize: 14 }}></i>
                    </span>
                    <input
                      id={`settings-${f.key}`}
                      type={f.key === 'support_email' ? 'email' : 'text'}
                      name={f.key}
                      className="form-control"
                      value={form[f.key] || ''}
                      onChange={handleChange}
                      placeholder={f.hint ? '' : '—'}
                    />
                  </div>
                  {f.hint && <div className="form-text mt-1">{f.hint}</div>}
                </div>
              ))}
            </div>
          </div>
        </div>
      ))}
    </div>
  );
};

export default Settings;