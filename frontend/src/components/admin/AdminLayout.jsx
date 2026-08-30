import { useState } from 'react';
import { Outlet } from 'react-router-dom';
import Sidebar from './Sidebar';
import Topbar from './Topbar';
import { useTheme } from '../../context/ThemeContext';
import '../../styles/admin.css';

const AdminLayout = () => {
  const [sidebarOpen, setSidebarOpen] = useState(false);
  const { theme } = useTheme();

  return (
    <div className="admin-layout d-flex" dir="ltr" lang="en" data-theme={theme}>
      <div className={`admin-sidebar ${sidebarOpen ? 'show' : ''}`}>
        <Sidebar />
      </div>

      <div className="admin-main flex-grow-1">
        <Topbar toggleSidebar={() => setSidebarOpen(!sidebarOpen)} />

        <div className="admin-content">
          <Outlet />
        </div>
      </div>

      {sidebarOpen && (
        <div
          className="sidebar-overlay d-lg-none"
          onClick={() => setSidebarOpen(false)}
        />
      )}
    </div>
  );
};

export default AdminLayout;
