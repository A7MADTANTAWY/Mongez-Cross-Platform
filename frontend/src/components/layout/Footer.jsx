import { Container, Row, Col, Button } from 'react-bootstrap';
import { useTranslation } from 'react-i18next';
import { useLandingData } from '../../context/LandingDataContext';
import { scrollToId } from '../../utils/scrollToId';

function phoneHref(phone) {
  if (!phone) return null;
  return `tel:${phone.replace(/[^+\d]/g, '')}`;
}

function Footer() {
  const { t } = useTranslation();
  const year = new Date().getFullYear();
  const { home } = useLandingData();
  const config = home?.config;

  const socials = [
    { key: 'facebook', label: t('footer_facebook'), url: config?.facebook_url },
    { key: 'twitter', label: t('footer_twitter'), url: config?.twitter_url },
    { key: 'instagram', label: t('footer_instagram'), url: config?.instagram_url },
    { key: 'linkedin', label: t('footer_linkedin'), url: config?.linkedin_url },
  ].filter((s) => s.url);

  const showStores = Boolean(config?.app_store_url || config?.play_store_url);

  const contactItems = [
    { icon: 'bi-geo-alt-fill', text: config?.address || t('footer_address') },
    { icon: 'bi-telephone-fill', text: config?.support_phone || t('footer_phone'), href: phoneHref(config?.support_phone || t('footer_phone')) },
    { icon: 'bi-envelope-fill', text: config?.support_email || t('footer_email'), href: config?.support_email ? `mailto:${config.support_email}` : (t('footer_email') ? `mailto:${t('footer_email')}` : null) },
    { icon: 'bi-clock-fill', text: config?.working_hours || t('footer_hours') },
  ];

  const serviceLinks = [
    t('footer_service_electricity'),
    t('footer_service_plumbing'),
    t('footer_service_gas'),
    t('footer_service_ac'),
    t('footer_service_appliances'),
    t('footer_service_carpentry'),
  ];

  const companyLinks = [
    { label: t('nav_services'), id: 'services' },
    { label: t('nav_how_it_works'), id: 'how-it-works' },
    { label: t('nav_why_choose'), id: 'why-choose' },
    { label: t('nav_app'), id: 'app' },
    { label: t('footer_company_contact'), id: 'emergency' },
  ];

  return (
    <footer className="site-footer">
      <Container className="py-5">
        <Row className="g-4">
          <Col lg={4} className="mb-4 mb-lg-0">
            <h4 className="fw-bold mb-3">
              <span style={{ color: 'var(--primary)' }}>Mongez</span>
            </h4>
            <p style={{ color: 'var(--footer-text)', lineHeight: 1.75, fontSize: 14, marginBottom: 20 }}>
              {t('footer_description')}
            </p>

            {socials.length > 0 && (
              <div className="mb-4">
                <h6 className="fw-semibold mb-3" style={{ fontSize: 13 }}>{t('footer_follow_us')}</h6>
                <div className="d-flex gap-2">
                  {socials.map((s) => (
                    <a key={s.key} href={s.url} target="_blank" rel="noopener noreferrer" aria-label={s.label} className="social-icon-link">
                      <i className={`bi bi-${s.key}`}></i>
                    </a>
                  ))}
                </div>
              </div>
            )}

            {showStores && (
              <div>
                <h6 className="fw-semibold mb-3" style={{ fontSize: 13 }}>{t('footer_download_app')}</h6>
                <div className="d-flex gap-2">
                  {config.app_store_url && (
                    <Button as="a" href={config.app_store_url} target="_blank" rel="noopener noreferrer" variant="outline-light" size="sm" className="rounded-pill px-3" style={{ fontSize: 12 }}>
                      <i className="bi bi-apple me-1"></i>{t('footer_app_store')}
                    </Button>
                  )}
                  {config.play_store_url && (
                    <Button as="a" href={config.play_store_url} target="_blank" rel="noopener noreferrer" variant="outline-light" size="sm" className="rounded-pill px-3" style={{ fontSize: 12 }}>
                      <i className="bi bi-google-play me-1"></i>{t('footer_google_play')}
                    </Button>
                  )}
                </div>
              </div>
            )}
          </Col>

          <Col lg={2} md={4} sm={6} className="mb-4">
            <h6 className="fw-semibold mb-3" style={{ fontSize: 13 }}>{t('footer_services_title')}</h6>
            <ul className="list-unstyled">
              {serviceLinks.map((s, i) => (
                <li key={i} className="mb-2">
                  <button type="button" className="footer-link footer-link-btn" onClick={() => scrollToId('services')}>{s}</button>
                </li>
              ))}
            </ul>
          </Col>

          <Col lg={2} md={4} sm={6} className="mb-4">
            <h6 className="fw-semibold mb-3" style={{ fontSize: 13 }}>{t('footer_company_title')}</h6>
            <ul className="list-unstyled">
              {companyLinks.map((c, i) => (
                <li key={i} className="mb-2">
                  <button type="button" className="footer-link footer-link-btn" onClick={() => scrollToId(c.id)}>{c.label}</button>
                </li>
              ))}
            </ul>
          </Col>

          <Col lg={4} md={4} className="mb-4">
            <h6 className="fw-semibold mb-3" style={{ fontSize: 13 }}>{t('footer_contact_title')}</h6>
            <ul className="list-unstyled mb-0">
              {contactItems.map((c, i) => (
                <li key={i} className="d-flex align-items-center gap-2 mb-2" style={{ color: 'var(--footer-text)', fontSize: 13 }}>
                  <i className={`bi ${c.icon}`} style={{ color: 'var(--primary)', fontSize: 13 }}></i>
                  {c.href ? <a className="footer-contact-link" href={c.href}>{c.text}</a> : c.text}
                </li>
              ))}
            </ul>
          </Col>
        </Row>

        <hr style={{ borderColor: 'rgba(255,255,255,0.08)', margin: '20px 0' }} />

        <div className="text-center">
          <p className="mb-0" style={{ color: 'rgba(255,255,255,0.35)', fontSize: 13 }}>
            &copy; {year} Mongez. {t('footer_rights')}
          </p>
        </div>
      </Container>
    </footer>
  );
}

export default Footer;