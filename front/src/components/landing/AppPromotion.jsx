import { Container, Row, Col, Button } from 'react-bootstrap';
import { useTranslation } from 'react-i18next';

function AppPromotion() {
  const { t, i18n } = useTranslation();
  const isRtl = i18n.language === 'ar';

  const features = [
    { icon: 'bi-shield-check', text: t('app_promotion_feature1_text') },
    { icon: 'bi-star-fill', text: t('app_promotion_feature2_text') },
    { icon: 'bi-download', text: t('app_promotion_feature3_text') },
  ];

  return (
    <section className="section-padding app-section" id="app">
      <Container>
        <Row className="align-items-center g-5">
          <Col lg={6} className={`order-lg-2 mb-4 mb-lg-0`}>
            <div className="fade-in text-center">
              <div className="position-relative d-inline-block">
                <div className="rounded-4 p-3" style={{ background: 'rgba(255,255,255,0.04)', border: '1px solid rgba(255,255,255,0.08)' }}>
                  <img
                    src="https://images.unsplash.com/photo-1512941937669-90a1b58e7e9c?auto=format&fit=crop&w=500&q=80"
                    alt={t('app_promotion_image_alt')}
                    className="rounded-3"
                    style={{ width: '100%', maxWidth: 340, boxShadow: '0 20px 40px rgba(0,0,0,0.3)' }}
                    loading="lazy"
                  />
                </div>

                <div className={`position-absolute d-none d-md-flex align-items-center gap-2 px-3 py-2 rounded-3 ${isRtl ? 'hero-float-2-rtl' : ''}`} style={{ top: '16%', left: isRtl ? 'auto' : '-15%', right: isRtl ? '-15%' : 'auto', background: 'rgba(255,255,255,0.95)', color: '#0f172a', boxShadow: '0 8px 24px rgba(0,0,0,0.15)' }}>
                  <div style={{ width: 26, height: 26, borderRadius: '50%', background: '#2ecc71', display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
                    <i className="bi bi-check-lg text-white" style={{ fontSize: 13 }}></i>
                  </div>
                  <span style={{ fontSize: 12, fontWeight: 600 }}>{t('app_promotion_feature1_text')}</span>
                </div>

                <div className={`position-absolute d-none d-md-flex align-items-center gap-2 px-3 py-2 rounded-3 ${isRtl ? 'hero-float-1-rtl' : ''}`} style={{ bottom: '10%', right: isRtl ? 'auto' : '-10%', left: isRtl ? '-10%' : 'auto', background: 'rgba(255,255,255,0.95)', color: '#0f172a', boxShadow: '0 8px 24px rgba(0,0,0,0.15)' }}>
                  <div style={{ width: 26, height: 26, borderRadius: '50%', background: '#f59e0b', display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
                    <i className="bi bi-star-fill text-white" style={{ fontSize: 11 }}></i>
                  </div>
                  <span style={{ fontSize: 12, fontWeight: 600 }}>{t('app_promotion_feature2_text')}</span>
                </div>
              </div>
            </div>
          </Col>

          <Col lg={6} className="order-lg-1">
            <div className="fade-in">
              <div className="section-badge" style={{ background: 'rgba(52,152,219,0.15)' }}>
                <i className="bi bi-phone"></i>
                {t('app_promotion_badge')}
              </div>

              <h2 className="section-title" style={{ textAlign: 'start', color: '#fff' }}>
                {t('app_promotion_title_part1')}{' '}
                <span style={{ color: '#60a5fa' }}>{t('app_promotion_title_part2')}</span>
              </h2>

              <p style={{ fontSize: 16, color: 'rgba(255,255,255,0.6)', lineHeight: 1.7, marginBottom: 28 }}>
                {t('app_promotion_description')}
              </p>

              <div className="d-flex flex-wrap gap-3 mb-4">
                {features.map((f, i) => (
                  <div key={i} className="d-flex align-items-center gap-2">
                    <i className={`bi ${f.icon}`} style={{ color: '#60a5fa', fontSize: 16 }}></i>
                    <span style={{ fontSize: 14, color: 'rgba(255,255,255,0.7)' }}>{f.text}</span>
                  </div>
                ))}
              </div>

              <div className="d-flex flex-wrap gap-3">
                <Button className="app-store-btn">
                  <i className="bi bi-apple fs-4"></i>
                  <div className="text-start">
                    <div style={{ fontSize: 10, color: '#94a3b8', lineHeight: 1.2 }}>{t('app_promotion_appstore_sub')}</div>
                    <div style={{ fontSize: 15, fontWeight: 600, lineHeight: 1.2 }}>{t('app_promotion_appstore')}</div>
                  </div>
                </Button>
                <Button className="app-store-btn">
                  <i className="bi bi-google-play fs-4"></i>
                  <div className="text-start">
                    <div style={{ fontSize: 10, color: '#94a3b8', lineHeight: 1.2 }}>{t('app_promotion_googleplay_sub')}</div>
                    <div style={{ fontSize: 15, fontWeight: 600, lineHeight: 1.2 }}>{t('app_promotion_googleplay')}</div>
                  </div>
                </Button>
              </div>
            </div>
          </Col>
        </Row>
      </Container>
    </section>
  );
}

export default AppPromotion;
