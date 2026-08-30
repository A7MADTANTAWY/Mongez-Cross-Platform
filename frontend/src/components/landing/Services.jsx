import { useState, useEffect } from 'react';
import { Container } from 'react-bootstrap';
import { useTranslation } from 'react-i18next';
import { categoriesAPI } from '../../services/api';

const ICONS = [
  { icon: 'bi-tools', color: '#2563eb' },
  { icon: 'bi-gear', color: '#10b981' },
  { icon: 'bi-wrench', color: '#ef4444' },
  { icon: 'bi-lightning', color: '#f59e0b' },
  { icon: 'bi-house', color: '#8b5cf6' },
  { icon: 'bi-cpu', color: '#06b6d4' },
  { icon: 'bi-thermometer-half', color: '#f97316' },
  { icon: 'bi-plug', color: '#ec4899' },
  { icon: 'bi-rulers', color: '#14b8a6' },
];

function Services() {
  const { t } = useTranslation();
  const [categories, setCategories] = useState([]);

  useEffect(() => {
    categoriesAPI.list()
      .then((res) => setCategories(res.data || []))
      .catch(() => setCategories([]));
  }, []);

  return (
    <section className="section-padding" id="services">
      <Container>
        <div className="section-header fade-in">
          <div className="section-badge">
            <i className="bi bi-tools"></i>
            {t('services_title')}
          </div>
          <h2 className="section-title">{t('services_title')}</h2>
          <p className="section-subtitle">{t('services_subtitle')}</p>
        </div>

        <div className="services-grid">
          {categories.map((cat, index) => {
            const ic = ICONS[index % ICONS.length];
            return (
              <div key={cat.id} className="service-card fade-in" style={{ animationDelay: `${index * 0.05}s` }}>
                <div className="mb-3 d-flex justify-content-center">
                  {cat.image ? (
                    <img src={cat.image} alt={cat.name} style={{ width: 56, height: 56, objectFit: 'contain' }} loading="lazy" />
                  ) : (
                    <div style={{
                      width: 60, height: 60, borderRadius: 16,
                      background: `${ic.color}10`,
                      display: 'flex', alignItems: 'center', justifyContent: 'center',
                    }}>
                      <i className={`bi ${ic.icon}`} style={{ fontSize: 28, color: ic.color }}></i>
                    </div>
                  )}
                </div>
                <div>
                  <div style={{ fontSize: 15, fontWeight: 600, color: 'var(--text)', marginBottom: 4 }}>
                    {cat.name}
                  </div>
                  {cat.description && (
                    <div style={{ fontSize: 12, color: 'var(--text-muted)', lineHeight: 1.5 }}>
                      {cat.description}
                    </div>
                  )}
                </div>
              </div>
            );
          })}
          {categories.length === 0 && (
            <div className="text-center py-5" style={{ gridColumn: '1 / -1' }}>
              <div className="spinner-border spinner-border-sm text-primary" role="status"></div>
            </div>
          )}
        </div>
      </Container>
    </section>
  );
}

export default Services;
