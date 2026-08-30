import { Container, Row, Col, Button } from 'react-bootstrap';
import { useTranslation } from 'react-i18next';

function Hero() {
  const { t, i18n } = useTranslation();
  const isRtl = i18n.language === 'ar';

  const stats = [
    { value: '15', unit: ' Min', label: t('hero_stat_avg_response_time'), icon: 'bi-lightning-fill' },
    { value: '10K+', unit: '', label: t('hero_stat_happy_customers'), icon: 'bi-people-fill' },
    { value: '4.9', unit: '/5', label: t('hero_stat_rating'), icon: 'bi-star-fill' },
  ];

  const features = [
    { icon: 'bi-shield-check', text: t('hero_feature_verified_technicians'), color: 'var(--secondary)' },
    { icon: 'bi-clock-history', text: t('hero_feature_24_7_support'), color: 'var(--primary)' },
    { icon: 'bi-award', text: t('hero_feature_100_satisfaction'), color: 'var(--accent)' },
  ];

  return (
    <section className="hero-section">
      <div className="hero-bg-orb hero-bg-orb-1" />
      <div className="hero-bg-orb hero-bg-orb-2" />

      <Container className="position-relative" style={{ zIndex: 2 }}>
        <Row className="align-items-center g-4 g-lg-5">
          <Col lg={6} className="mb-4 mb-lg-0">
            <div className="fade-in">
              <div className="hero-badge">
                <span className="hero-badge-dot" />
                <span>{t('hero_trusted_badge')}</span>
              </div>

              <h1 className="hero-title">
                {t('hero_main_headline_part1')}{' '}
                <span className="hero-title-gradient">
                  {t('hero_main_headline_part2')}
                </span>
              </h1>

              <p className="hero-subtitle">
                {t('hero_subtitle')}
              </p>

              <div className="row g-3 mb-4">
                {features.map((f, i) => (
                  <Col xs={12} sm={4} key={i}>
                    <div className="hero-feature">
                      <div className="hero-feature-icon" style={{ background: `${f.color}12` }}>
                        <i className={`bi ${f.icon}`} style={{ color: f.color, fontSize: 16 }}></i>
                      </div>
                      <span>{f.text}</span>
                    </div>
                  </Col>
                ))}
              </div>

              <div className="d-flex flex-wrap gap-3 mb-4">
                <Button className="hero-cta-primary">
                  <i className={`bi bi-download ${isRtl ? 'ms-2' : 'me-2'}`}></i>
                  {t('hero_download_button')}
                </Button>
                <Button className="hero-cta-secondary" href="#how-it-works">
                  <i className={`bi bi-play-circle ${isRtl ? 'ms-2' : 'me-2'}`}></i>
                  {t('hero_how_it_works_button')}
                </Button>
              </div>

              <div className="hero-stats">
                {stats.map((s, i) => (
                  <div key={i} className="hero-stat">
                    <div className="hero-stat-icon">
                      <i className={`bi ${s.icon}`}></i>
                    </div>
                    <div>
                      <div className="hero-stat-value">{s.value}<span className="hero-stat-unit">{s.unit}</span></div>
                      <div className="hero-stat-label">{s.label}</div>
                    </div>
                  </div>
                ))}
              </div>
            </div>
          </Col>

          <Col lg={6}>
            <div className="fade-in fade-in-d2 hero-image-wrap">
              <div className="hero-image-container">
                <img
                  src="https://images.unsplash.com/photo-1621905252507-b35492cc74b4?auto=format&fit=crop&w=800&q=80"
                  alt={t('hero_image_alt')}
                  className="hero-image"
                  loading="eager"
                />

                <div className={`hero-float-card hero-float-1 ${isRtl ? 'hero-float-1-rtl' : ''}`}>
                  <div className="hero-float-icon" style={{ background: 'var(--secondary)' }}>
                    <i className="bi bi-check-lg text-white"></i>
                  </div>
                  <div>
                    <div className="hero-float-title">{t('hero_floating_verified_title')}</div>
                    <div className="hero-float-desc">{t('hero_floating_verified_desc')}</div>
                  </div>
                </div>

                <div className={`hero-float-card hero-float-2 ${isRtl ? 'hero-float-2-rtl' : ''}`}>
                  <div className="hero-float-icon" style={{ background: 'var(--warning)' }}>
                    <i className="bi bi-star-fill text-white" style={{ fontSize: 13 }}></i>
                  </div>
                  <div>
                    <div className="hero-float-title">4.9/5</div>
                    <div className="hero-float-desc">{t('hero_floating_rating_label')}</div>
                  </div>
                </div>

                <div className="hero-float-card hero-float-3">
                  <div className="hero-float-icon" style={{ background: 'var(--primary)' }}>
                    <i className="bi bi-clock-fill text-white" style={{ fontSize: 13 }}></i>
                  </div>
                  <div>
                    <div className="hero-float-title">{t('hero_floating_24_7_title')}</div>
                    <div className="hero-float-desc">{t('hero_floating_24_7_desc')}</div>
                  </div>
                </div>
              </div>
            </div>
          </Col>
        </Row>
      </Container>
    </section>
  );
}

export default Hero;
