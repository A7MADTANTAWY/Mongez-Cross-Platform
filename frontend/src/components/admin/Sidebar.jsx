import { NavLink, useNavigate } from 'react-router-dom';
import { useAuth } from '../../context/AuthContext';
import { useTheme } from '../../context/ThemeContext';

const menuItems = [
  { path: '/admin', label: 'Dashboard', icon: 'bi-speedometer2', end: true },
  { path: '/admin/users', label: 'Users', icon: 'bi-people' },
  { path: '/admin/workers', label: 'Workers', icon: 'bi-person-badge' },
  { path: '/admin/categories', label: 'Categories', icon: 'bi-grid' },
  { path: '/admin/orders', label: 'Orders', icon: 'bi-cart-check' },
  { path: '/admin/ratings', label: 'Ratings', icon: 'bi-star' },
  { path: '/admin/settings', label: 'Site Settings', icon: 'bi-gear' },
];

const Sidebar = () => {
  const { user } = useAuth();
  const { theme, toggleTheme } = useTheme();
  const navigate = useNavigate();

  return (
    <div
      className="d-flex flex-column"
      style={{
        width: 260, height: '100vh',
        background: 'linear-gradient(180deg, #1e293b 0%, #0f172a 100%)',
        position: 'fixed', top: 0, left: 0, right: 'auto',
        zIndex: 1040, overflowY: 'auto',
        borderRight: '1px solid rgba(255,255,255,0.06)',
      }}
    >
      <div
        className="d-flex align-items-center py-4 px-4 border-bottom"
        style={{ borderColor: 'rgba(255,255,255,0.08)', cursor: 'pointer' }}
        onClick={() => navigate('/admin')}
      >
        <img
          src="/logo.jpg"
          alt="Mongez"
          style={{ width: 40, height: 40, objectFit: 'cover', borderRadius: 10 }}
          className="me-3"
        />
        <div className="d-flex flex-column lh-sm">
          <span className="fw-bold text-white" style={{ fontSize: 18, letterSpacing: '-0.3px' }}>
            Mongez
          </span>
          <span className="text-white-50" style={{ fontSize: 12, fontWeight: 500 }}>
            Admin Panel
          </span>
        </div>
      </div>

      <div className="px-3 mt-3 flex-grow-1">
        <p className="text-uppercase small text-white-50 mb-2 px-3" style={{ fontSize: 11, letterSpacing: 1.2, fontWeight: 600 }}>
          Main Menu
        </p>
        <nav className="nav flex-column">
          {menuItems.map((item) => (
            <NavLink
              key={item.path}
              to={item.path}
              end={item.end}
              className={({ isActive }) =>
                `nav-link d-flex align-items-center px-3 py-2.5 mb-1 rounded-3 ${isActive ? 'text-white' : 'text-white-50'}`
              }
              style={({ isActive }) => ({
                backgroundColor: isActive ? 'rgba(99, 102, 241, 0.12)' : 'transparent',
                borderLeft: isActive ? '3px solid #818cf8' : '3px solid transparent',
                transition: 'all 0.2s ease',
                fontSize: 14,
                fontWeight: isActive ? 600 : 400,
              })}
            >
              <i className={`bi ${item.icon} me-3 fs-5`}></i>
              {item.label}
            </NavLink>
          ))}
        </nav>
      </div>

      <div className="mt-auto p-3 border-top" style={{ borderColor: 'rgba(255,255,255,0.08)' }}>
        <button
          onClick={toggleTheme}
          className="w-100 d-flex align-items-center gap-2 px-3 py-2 mb-3 rounded-3 border-0"
          style={{
            background: 'rgba(255,255,255,0.06)',
            color: 'rgba(255,255,255,0.7)',
            fontSize: 13, fontWeight: 500,
            cursor: 'pointer',
            transition: 'all 0.2s ease',
          }}
          onMouseEnter={(e) => { e.currentTarget.style.background = 'rgba(255,255,255,0.1)'; }}
          onMouseLeave={(e) => { e.currentTarget.style.background = 'rgba(255,255,255,0.06)'; }}
        >
          <i className={`bi ${theme === 'dark' ? 'bi-sun-fill' : 'bi-moon-stars'}`}></i>
          {theme === 'dark' ? 'Light Mode' : 'Dark Mode'}
        </button>

        <div className="d-flex align-items-center px-3">
          <div
            className="d-flex align-items-center justify-content-center rounded-circle me-3"
            style={{
              width: 36, height: 36,
              background: 'linear-gradient(135deg, #667eea, #764ba2)',
              fontSize: 14, fontWeight: 600, color: '#fff', flexShrink: 0,
            }}
          >
            {user?.username?.charAt(0).toUpperCase() || 'A'}
          </div>
          <div className="text-white" style={{ fontSize: 13 }}>
            <div className="fw-semibold" style={{ lineHeight: 1.2 }}>{user?.username || 'Admin'}</div>
            <small className="text-white-50">{user?.role || 'admin'}</small>
          </div>
        </div>
      </div>
    </div>
  );
};

export default Sidebar;
