import { useAuth } from '../../context/AuthContext';
import { useTheme } from '../../context/ThemeContext';
import logo from '../../assets/images/a.png';

const Topbar = ({ toggleSidebar }) => {
  const { user, logout } = useAuth();
  const { theme, toggleTheme } = useTheme();

  return (
    <nav
      className="navbar navbar-expand px-4 py-3 shadow-sm"
      style={{
        backgroundColor: 'var(--admin-topbar-bg)',
        borderBottom: '1px solid var(--admin-topbar-border)',
        backdropFilter: 'blur(12px)',
        WebkitBackdropFilter: 'blur(12px)',
        position: 'fixed',
        top: 0, left: 0, right: 0,
        zIndex: 1030,
        height: '64px',
        transition: 'background-color 0.3s ease',
      }}
    >
      <div className="d-flex align-items-center w-100">
        <button
          className="btn btn-link p-0 me-3 d-lg-none"
          onClick={toggleSidebar}
          style={{ textDecoration: 'none', color: 'var(--admin-text)' }}
        >
          <i className="bi bi-list fs-4"></i>
        </button>

        <div className="d-flex align-items-center d-lg-none">
          <img
            src={logo}
            alt="Mongez"
            style={{ width: '28px', height: '28px', objectFit: 'contain' }}
            className="me-2"
          />
          <span className="fw-bold" style={{ color: 'var(--admin-text)' }}>Mongez</span>
        </div>

        <div className="ms-auto d-flex align-items-center gap-3">
          <button
            className="admin-theme-toggle"
            onClick={toggleTheme}
            title={theme === 'light' ? 'Dark mode' : 'Light mode'}
          >
            <i className={`bi ${theme === 'light' ? 'bi-moon-stars' : 'bi-sun-fill'}`}></i>
          </button>

          <div className="d-none d-md-flex align-items-center gap-2 px-3 py-1 rounded-pill" style={{ backgroundColor: 'var(--admin-primary-light)' }}>
            <i className="bi bi-person-circle" style={{ color: 'var(--admin-text-secondary)' }}></i>
            <span style={{ fontSize: '14px', color: 'var(--admin-text-secondary)' }}>
              {user?.username || 'Admin'}
            </span>
            <span
              className="badge rounded-pill"
              style={{
                fontSize: '10px',
                background: 'linear-gradient(135deg, #667eea, #764ba2)',
              }}
            >
              {user?.role || 'admin'}
            </span>
          </div>

          <button
            className="btn btn-link text-decoration-none p-0 position-relative"
            style={{ color: 'var(--admin-text-secondary)' }}
            title="Notifications"
          >
            <i className="bi bi-bell fs-5"></i>
            <span
              className="position-absolute top-0 start-100 translate-middle badge rounded-pill"
              style={{
                fontSize: '9px',
                background: 'linear-gradient(135deg, #ff6b6b, #ee5a52)',
                padding: '2px 5px',
              }}
            >
              0
            </span>
          </button>

          <button
            className="btn btn-link text-decoration-none p-0"
            style={{ color: '#ef4444' }}
            title="Logout"
            onClick={logout}
          >
            <i className="bi bi-box-arrow-right fs-5"></i>
          </button>
        </div>
      </div>
    </nav>
  );
};

export default Topbar;
