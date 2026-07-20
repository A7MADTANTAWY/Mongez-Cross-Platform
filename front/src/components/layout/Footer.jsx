import { Container, Row, Col, Form, Button } from 'react-bootstrap';
import { useTranslation } from 'react-i18next';

function Footer() {
  const { t } = useTranslation();
  const year = new Date().getFullYear();

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

            <div className="mb-4">
              <h6 className="fw-semibold mb-3" style={{ fontSize: 13 }}>{t('footer_follow_us')}</h6>
              <div className="d-flex gap-2">
                {['facebook', 'twitter', 'instagram', 'linkedin'].map((p) => (
                  <a key={p} href="#" className="social-icon-link">
                    <i className={`bi bi-${p}`}></i>
                  </a>
                ))}
              </div>
            </div>

            <div>
              <h6 className="fw-semibold mb-3" style={{ fontSize: 13 }}>{t('footer_download_app')}</h6>
              <div className="d-flex gap-2">
                <Button variant="outline-light" size="sm" className="rounded-pill px-3" style={{ fontSize: 12 }}>
                  <i className="bi bi-apple me-1"></i>{t('footer_app_store')}
                </Button>
                <Button variant="outline-light" size="sm" className="rounded-pill px-3" style={{ fontSize: 12 }}>
                  <i className="bi bi-google-play me-1"></i>{t('footer_google_play')}
                </Button>
              </div>
            </div>
          </Col>

          <Col lg={2} md={4} sm={6} className="mb-4">
            <h6 className="fw-semibold mb-3" style={{ fontSize: 13 }}>{t('footer_services_title')}</h6>
            <ul className="list-unstyled">
              {[t('footer_service_electricity'), t('footer_service_plumbing'), t('footer_service_gas'), t('footer_service_ac'), t('footer_service_appliances'), t('footer_service_carpentry')].map((s, i) => (
                <li key={i} className="mb-2">
                  <a href="#" className="footer-link">{s}</a>
                </li>
              ))}
            </ul>
          </Col>

          <Col lg={2} md={4} sm={6} className="mb-4">
            <h6 className="fw-semibold mb-3" style={{ fontSize: 13 }}>{t('footer_company_title')}</h6>
            <ul className="list-unstyled">
              {[t('footer_company_about'), t('footer_company_careers'), t('footer_company_press'), t('footer_company_blog'), t('footer_company_partners'), t('footer_company_contact')].map((s, i) => (
                <li key={i} className="mb-2">
                  <a href="#" className="footer-link">{s}</a>
                </li>
              ))}
            </ul>
          </Col>

          <Col lg={4} md={4} className="mb-4">
            <h6 className="fw-semibold mb-3" style={{ fontSize: 13 }}>{t('footer_contact_title')}</h6>
            <ul className="list-unstyled mb-4">
              {[
                { icon: 'bi-geo-alt-fill', text: t('footer_address') },
                { icon: 'bi-telephone-fill', text: t('footer_phone') },
                { icon: 'bi-envelope-fill', text: t('footer_email') },
                { icon: 'bi-clock-fill', text: t('footer_hours') },
              ].map((c, i) => (
                <li key={i} className="d-flex align-items-center gap-2 mb-2" style={{ color: 'var(--footer-text)', fontSize: 13 }}>
                  <i className={`bi ${c.icon}`} style={{ color: 'var(--primary)', fontSize: 13 }}></i>
                  {c.text}
                </li>
              ))}
            </ul>

            <h6 className="fw-semibold mb-3" style={{ fontSize: 13 }}>{t('footer_newsletter_title')}</h6>
            <Form className="d-flex gap-2">
              <Form.Control
                type="email"
                placeholder={t('footer_newsletter_placeholder')}
                className="rounded-pill"
                style={{ background: 'rgba(255,255,255,0.06)', border: '1px solid rgba(255,255,255,0.12)', color: '#fff', padding: '8px 14px', fontSize: 13 }}
              />
              <Button variant="primary" className="rounded-pill px-3" style={{ background: 'var(--primary)', borderColor: 'var(--primary)' }}>
                <i className="bi bi-send"></i>
              </Button>
            </Form>
          </Col>
        </Row>

        <hr style={{ borderColor: 'rgba(255,255,255,0.08)', margin: '20px 0' }} />

        <div className="d-flex flex-wrap justify-content-between align-items-center gap-2">
          <p className="mb-0" style={{ color: 'rgba(255,255,255,0.35)', fontSize: 13 }}>
            &copy; {year} Mongez. {t('footer_rights')}
          </p>
          <div className="d-flex gap-3">
            {[t('footer_privacy'), t('footer_terms'), t('footer_cookie')].map((l, i) => (
              <a key={i} href="#" className="footer-link" style={{ fontSize: 13 }}>{l}</a>
            ))}
          </div>
        </div>
      </Container>
    </footer>
  );
}

export default Footer;
