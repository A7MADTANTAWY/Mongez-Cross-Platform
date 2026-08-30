import { Container, Row, Col, Button } from 'react-bootstrap';
import { useTranslation } from 'react-i18next';

function EmergencySection() {
  const { t } = useTranslation();

  const features = [
    { icon: 'bi-patch-check-fill', text: t('emergency_feature_licensed') },
    { icon: 'bi-lightning-charge-fill', text: t('emergency_feature_dispatch') },
    { icon: 'bi-shield-check', text: t('emergency_feature_fees') },
  ];

  return (
    <section className="section-padding">
      <Container>
        <div className="emergency-card p-4 p-lg-5">
          <Row className="align-items-center g-4">
            <Col lg={7}>
              <div className="fade-in">
                <div className="section-badge" style={{ background: 'rgba(239,68,68,0.08)', color: '#ef4444' }}>
                  <i className="bi bi-exclamation-triangle-fill"></i>
                  {t('emergency_response_badge')}
                </div>

                <h2 className="section-title" style={{ textAlign: 'start' }}>
                  {t('emergency_title_part1')}{' '}
                  <span style={{ color: '#ef4444' }}>{t('emergency_title_part2')}</span>
                </h2>

                <p style={{ fontSize: 15, color: 'var(--text-secondary)', lineHeight: 1.75, marginBottom: 20 }}>
                  {t('emergency_description')}
                </p>

                <div className="d-flex flex-wrap gap-2 mb-4">
                  {features.map((f, i) => (
                    <div key={i} className="d-inline-flex align-items-center gap-2 px-3 py-2 rounded-pill" style={{ background: 'var(--bg-alt)', border: '1px solid var(--border)', fontSize: 13, fontWeight: 500, color: 'var(--text)' }}>
                      <i className={`bi ${f.icon}`} style={{ color: '#ef4444', fontSize: 14 }}></i>
                      {f.text}
                    </div>
                  ))}
                </div>
              </div>
            </Col>

            <Col lg={5}>
              <div className="fade-in fade-in-d2 text-center">
                <div className="emergency-phone-box">
                  <div style={{ width: 48, height: 48, borderRadius: '50%', background: 'rgba(255,255,255,0.2)', display: 'flex', alignItems: 'center', justifyContent: 'center', marginBottom: 12 }}>
                    <i className="bi bi-telephone-outbound-fill fs-4"></i>
                  </div>
                  <div style={{ fontSize: 12, opacity: 0.85, marginBottom: 4 }}>{t('emergency_hotline_label')}</div>
                  <div style={{ fontSize: 30, fontWeight: 800, letterSpacing: 2, marginBottom: 12 }}>{t('emergency_phone')}</div>
                  <Button variant="light" className="rounded-pill px-4 py-2 fw-semibold" style={{ color: '#dc2626', fontSize: 14 }}>
                    <i className="bi bi-telephone me-2"></i>
                    {t('emergency_phone')}
                  </Button>
                </div>

                <div className="mt-4">
                  <div style={{ fontSize: 12, color: 'var(--text-muted)' }}>{t('emergency_response_time_label')}</div>
                  <div style={{ fontSize: 17, fontWeight: 700, color: 'var(--text)' }}>{t('emergency_response_time_value')}</div>
                </div>
              </div>
            </Col>
          </Row>
        </div>
      </Container>
    </section>
  );
}

export default EmergencySection;
