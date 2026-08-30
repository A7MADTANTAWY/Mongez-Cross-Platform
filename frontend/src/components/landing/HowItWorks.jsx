import { Container, Row, Col } from 'react-bootstrap';
import { useTranslation } from 'react-i18next';

function HowItWorks() {
  const { t } = useTranslation();

  const steps = [
    {
      id: 1,
      title: t('how_it_works_step1_title'),
      desc: t('how_it_works_step1_desc'),
      icon: 'bi-search-heart',
      subs: [t('how_it_works_step1_sub1'), t('how_it_works_step1_sub2'), t('how_it_works_step1_sub3')],
    },
    {
      id: 2,
      title: t('how_it_works_step2_title'),
      desc: t('how_it_works_step2_desc'),
      icon: 'bi-person-check',
      subs: [t('how_it_works_step2_sub1'), t('how_it_works_step2_sub2'), t('how_it_works_step2_sub3')],
    },
    {
      id: 3,
      title: t('how_it_works_step3_title'),
      desc: t('how_it_works_step3_desc'),
      icon: 'bi-check-all',
      subs: [t('how_it_works_step3_sub1'), t('how_it_works_step3_sub2'), t('how_it_works_step3_sub3')],
    },
  ];

  return (
    <section className="section-padding" id="how-it-works">
      <Container>
        <div className="section-header fade-in">
          <div className="section-badge">
            <i className="bi bi-play-circle"></i>
            {t('how_it_works_badge')}
          </div>
          <h2 className="section-title">
            {t('how_it_works_title_part1')}{' '}
            <span style={{ color: 'var(--primary)' }}>Mongez</span>{' '}
            {t('how_it_works_title_part2')}
          </h2>
          <p className="section-subtitle">{t('how_it_works_subtitle')}</p>
        </div>

        <Row className="g-4">
          {steps.map((step, index) => (
            <Col key={step.id} lg={4} md={6}>
              <div className="step-card fade-in" style={{ animationDelay: `${index * 0.12}s` }}>
                <div className="d-flex align-items-center gap-3 mb-3">
                  <div className="step-number">{step.id}</div>
                  <div className="step-icon-box">
                    <i className={`bi ${step.icon}`} style={{ fontSize: 20, color: 'var(--primary)' }}></i>
                  </div>
                </div>

                <h3 style={{ fontSize: '1.15rem', fontWeight: 700, color: 'var(--text)', marginBottom: 8 }}>{step.title}</h3>
                <p style={{ fontSize: 14, color: 'var(--text-secondary)', lineHeight: 1.7, marginBottom: 16 }}>{step.desc}</p>

                <div className="step-subs">
                  <ul className="list-unstyled mb-0">
                    {step.subs.map((sub, idx) => (
                      <li key={idx} className="step-sub-item">
                        <i className="bi bi-check-circle-fill"></i>
                        {sub}
                      </li>
                    ))}
                  </ul>
                </div>
              </div>
            </Col>
          ))}
        </Row>
      </Container>
    </section>
  );
}

export default HowItWorks;
