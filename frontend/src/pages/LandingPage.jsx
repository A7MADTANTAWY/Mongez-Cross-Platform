import { useEffect } from 'react';
import Header from '../components/layout/Header';
import Hero from '../components/landing/Hero';
import Services from '../components/landing/Services';
import HowItWorks from '../components/landing/HowItWorks';
import WhyChoose from '../components/landing/WhyChoose';
import AppPromotion from '../components/landing/AppPromotion';
import EmergencySection from '../components/landing/EmergencySection';
import Footer from '../components/layout/Footer';
import { LandingDataProvider } from '../context/LandingDataContext';
import { useTranslation } from 'react-i18next';
import { useTheme } from '../context/ThemeContext';
import './Landing.css';

function LandingPage() {
  const { i18n } = useTranslation();
  const { theme } = useTheme();

  useEffect(() => {
    document.documentElement.dir = i18n.language === 'ar' ? 'rtl' : 'ltr';
    document.documentElement.lang = i18n.language;
  }, [i18n.language]);

  return (
    <div className="landing-page" data-theme={theme} dir={i18n.language === 'ar' ? 'rtl' : 'ltr'}>
      <LandingDataProvider>
        <Header />
        <main>
          <Hero />
          <Services />
          <HowItWorks />
          <WhyChoose />
          <AppPromotion />
          <EmergencySection />
        </main>
        <Footer />
      </LandingDataProvider>
    </div>
  );
}

export default LandingPage;
