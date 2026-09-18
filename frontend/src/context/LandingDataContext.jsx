import { createContext, useCallback, useContext, useEffect, useState } from 'react';
import { siteAPI } from '../services/api';

// Shares the public landing payload ({ config, stats }) fetched once for the
// whole page instead of each section requesting /home/ separately. `home` is
// null while loading / on error — sections then render clear placeholders
// instead of fabricated numbers.
const LandingDataContext = createContext({ home: null, refresh: () => {} });

// eslint-disable-next-line react-refresh/only-export-components
export const useLandingData = () => useContext(LandingDataContext);

export function LandingDataProvider({ children }) {
  const [home, setHome] = useState(null);

  const refresh = useCallback(() => {
    siteAPI.home()
      .then((res) => setHome(res.data))
      .catch(() => setHome(null));
  }, []);

  useEffect(() => {
    refresh();
  }, [refresh]);

  return (
    <LandingDataContext.Provider value={{ home, refresh }}>
      {children}
    </LandingDataContext.Provider>
  );
}