import { Container, Row, Col } from 'react-bootstrap';
import { useTranslation } from 'react-i18next';

function WhyChoose() {
  const { t } = useTranslation();

  const features = [
    { title: t('why_choose_feature1_title'), desc: t('why_choose_feature1_desc'), stats: t('why_choose_feature1_stats'), icon: 'bi-shield-check', color: 'var(--secondary)' },
    { title: t('why_choose_feature2_title'), desc: t('why_choose_feature2_desc'), stats: t('why_choose_feature2_stats'), icon: 'bi-lightning-charge', color: 'var(--primary)' },
    { title: t('why_choose_feature3_title'), desc: t('why_choose_feature3_desc'), stats: t('why_choose_feature3_stats'), icon: 'bi-star-fill', color: 'var(--warning)' },
    { title: t('why_choose_feature4_title'), desc: t('why_choose_feature4_desc'), stats: t('why_choose_feature4_stats'), icon: 'bi-lock-fill', color: 'var(--accent)' },
  ];

  return (
    <section className="section-padding" id="why-choose">
      <Container>
        <Row className="align-items-center g-5">
          <Col lg={5} className="mb-4 mb-lg-0">
            <div className="fade-in">
              <div className="section-badge">
                <i className="bi bi-award"></i>
                {t('why_choose_title')}
              </div>
              <h2 className="section-title" style={{ textAlign: 'start' }}>
                {t('why_choose_title')} <span style={{ color: 'var(--primary)' }}>Mongez</span>?
              </h2>
              <p style={{ fontSize: 16, color: 'var(--text-secondary)', lineHeight: 1.75, marginBottom: 28 }}>
                {t('why_choose_subtitle')}
              </p>

              <div className="d-flex align-items-center gap-3 p-4 rounded-4" style={{ background: 'var(--bg-alt)', border: '1px solid var(--card-border)' }}>
                <div style={{
                  width: 50, height: 50, borderRadius: 14,
                  background: 'linear-gradient(135deg, #f59e0b, #d97706)',
                  display: 'flex', alignItems: 'center', justifyContent: 'center', flexShrink: 0,
                }}>
                  <i className="bi bi-award-fill text-white fs-5"></i>
                </div>
                <div>
                  <h6 className="fw-bold mb-1" style={{ fontSize: 14, color: 'var(--text)' }}>{t('why_choose_award_title')}</h6>
                  <p className="mb-0" style={{ fontSize: 13, color: 'var(--text-secondary)' }}>{t('why_choose_award_desc')}</p>
                </div>
              </div>
            </div>
          </Col>

          <Col lg={7}>
            <Row className="g-3">
              {features.map((f, i) => (
                <Col sm={6} key={i}>
                  <div className="feature-card fade-in" style={{ animationDelay: `${i * 0.08}s` }}>
                    <div className="d-flex align-items-start gap-3 mb-3">
                      <div style={{
                        width: 46, height: 46, borderRadius: 14,
                        background: `${f.color}12`,
                        display: 'flex', alignItems: 'center', justifyContent: 'center', flexShrink: 0,
                      }}>
                        <i className={`bi ${f.icon}`} style={{ fontSize: 20, color: f.color }}></i>
                      </div>
                      <div>
                        <h6 className="fw-bold mb-1" style={{ fontSize: 14, color: 'var(--text)' }}>{f.title}</h6>
                        <span className="badge rounded-pill" style={{ background: `${f.color}12`, color: f.color, fontSize: 11, fontWeight: 600 }}>{f.stats}</span>
                      </div>
                    </div>
                    <p className="mb-0" style={{ fontSize: 13, color: 'var(--text-secondary)', lineHeight: 1.65 }}>{f.desc}</p>
                  </div>
                </Col>
              ))}
            </Row>
          </Col>
        </Row>
      </Container>
    </section>
  );
}

export default WhyChoose;
