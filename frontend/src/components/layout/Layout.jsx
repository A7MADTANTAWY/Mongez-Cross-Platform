import Header from './Header';
import { Outlet } from 'react-router-dom';

function Layout() {
  return (
    <div className="layout">
      <Header />
      <main className="flex-grow-1">
        <Outlet />
      </main>
    </div>
  );
}

export default Layout;