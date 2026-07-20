import { useState, useEffect } from 'react';
import { Container, Button, Offcanvas, Dropdown } from 'react-bootstrap';
import { Link } from 'react-router-dom';
import { useTranslation } from 'react-i18next';
import { useTheme } from '../../context/ThemeContext';
import logo from '../../assets/images/a.png';

function Header() {
  const { t, i18n } = useTranslation();
  const { theme, toggleTheme } = useTheme();
  const [scrolled, setScrolled] = useState(false);
  const [showOffcanvas, setShowOffcanvas] = useState(false);
  const isRtl = i18n.language === 'ar';

  const changeLanguage = (lng) => {
    i18n.changeLanguage(lng);
    document.documentElement.dir = lng === 'ar' ? 'rtl' : 'ltr';
    setShowOffcanvas(false);
  };

  useEffect(() => {
    const onScroll = () => setScrolled(window.scrollY > 40);
    window.addEventListener('scroll', onScroll, { passive: true });
    return () => window.removeEventListener('scroll', onScroll);
  }, []);

  const navItems = [
    { id: 1, nameKey: 'nav_services', href: '#services' },
    { id: 2, nameKey: 'nav_how_it_works', href: '#how-it-works' },
    { id: 3, nameKey: 'nav_why_choose', href: '#why-choose' },
    { id: 4, nameKey: 'nav_app', href: '#app' },
  ];

  const scrollTo = (sel) => {
    document.querySelector(sel)?.scrollIntoView({ behavior: 'smooth' });
    setShowOffcanvas(false);
  };

  const langLabel = (i18n.language || 'ar') === 'ar' ? 'عربي' : 'EN';

  return (
    <>
      <header
        className={`site-header ${scrolled ? 'scrolled' : ''}`}
        style={{ direction: isRtl ? 'rtl' : 'ltr' }}
      >
        <Container className="d-flex align-items-center justify-content-between" style={{ height: 60 }}>
          <Link to="/" className="d-flex align-items-center gap-2 text-decoration-none">
            <img src={logo} alt="Mongez" style={{ width: 32, height: 32, objectFit: 'contain' }} />
            <span className="fw-bold" style={{ fontSize: 19, color: 'var(--primary)', lineHeight: 1 }}>Mongez</span>
          </Link>

          <nav className="d-none d-lg-flex align-items-center gap-1">
            {navItems.map((item) => (
              <button key={item.id} className="nav-link-btn" onClick={() => scrollTo(item.href)}>
                {t(item.nameKey)}
              </button>
            ))}
          </nav>

          <div className="d-flex align-items-center gap-2">
            <button className="theme-toggle" onClick={toggleTheme} title={theme === 'light' ? 'Dark mode' : 'Light mode'}>
              <i className={`bi ${theme === 'light' ? 'bi-moon-stars' : 'bi-sun-fill'}`}></i>
            </button>

            <Dropdown align={isRtl ? 'start' : 'end'}>
              <Dropdown.Toggle variant="link" className="lang-toggle">
                <i className="bi bi-globe2"></i>
                <span>{langLabel}</span>
              </Dropdown.Toggle>
              <Dropdown.Menu>
                <Dropdown.Item onClick={() => changeLanguage('en')} active={(i18n.language || 'ar') === 'en'}>English</Dropdown.Item>
                <Dropdown.Item onClick={() => changeLanguage('ar')} active={(i18n.language || 'ar') === 'ar'}>العربية</Dropdown.Item>
              </Dropdown.Menu>
            </Dropdown>

            <Button className="d-lg-none menu-btn" onClick={() => setShowOffcanvas(true)}>
              <i className="bi bi-list"></i>
            </Button>
          </div>
        </Container>
      </header>

      <Offcanvas
        show={showOffcanvas}
        onHide={() => setShowOffcanvas(false)}
        placement={isRtl ? 'start' : 'end'}
        style={{ maxWidth: 300, background: 'var(--bg)', color: 'var(--text)' }}
      >
        <Offcanvas.Header closeButton>
          <Offcanvas.Title className="d-flex align-items-center gap-2 fw-bold">
            <img src={logo} alt="Mongez" style={{ width: 26, height: 26, objectFit: 'contain' }} />
            <span style={{ color: 'var(--primary)' }}>Mongez</span>
          </Offcanvas.Title>
        </Offcanvas.Header>
        <Offcanvas.Body>
          <nav className="d-flex flex-column gap-1">
            {navItems.map((item) => (
              <button
                key={item.id}
                className="btn btn-link text-decoration-none text-start py-2 px-3 rounded-3"
                style={{ color: 'var(--text)', fontSize: 15, fontWeight: 500 }}
                onClick={() => scrollTo(item.href)}
              >
                {t(item.nameKey)}
              </button>
            ))}
          </nav>
          <hr style={{ borderColor: 'var(--border)' }} />
          <div className="px-3 mb-3">
            <button className="theme-toggle w-100 d-flex align-items-center justify-content-center gap-2" onClick={toggleTheme}>
              <i className={`bi ${theme === 'light' ? 'bi-moon-stars' : 'bi-sun-fill'}`}></i>
              <span style={{ fontSize: 14 }}>{theme === 'light' ? 'Dark Mode' : 'Light Mode'}</span>
            </button>
          </div>
          <div className="d-flex gap-2 px-3">
            <Button
              variant={(i18n.language || 'ar') === 'en' ? 'primary' : 'outline-primary'}
              className="flex-fill rounded-pill" size="sm"
              onClick={() => changeLanguage('en')}
            >
              English
            </Button>
            <Button
              variant={(i18n.language || 'ar') === 'ar' ? 'primary' : 'outline-primary'}
              className="flex-fill rounded-pill" size="sm"
              onClick={() => changeLanguage('ar')}
            >
              العربية
            </Button>
          </div>
        </Offcanvas.Body>
      </Offcanvas>
    </>
  );
}

export default Header;
