import React, { useState, useCallback } from 'react';
import { useNavigate } from 'react-router-dom';
import { adminAPI } from '../../services/api';
import Table from '../../components/admin/Table';
import { usePolling, useTimeAgo } from '../../hooks/usePolling';
import { useDebouncedValue } from '../../hooks/useDebouncedValue';
import ExportCsvButton from '../../components/admin/ExportCsvButton';

const VERIFICATION_LABELS = {
  pending: 'Pending',
  verified: 'Verified',
  rejected: 'Rejected',
};

const VERIFICATION_COLORS = {
  pending: { bg: '#fef3c7', fg: '#92400e' },
  verified: { bg: '#dcfce7', fg: '#166534' },
  rejected: { bg: '#fee2e2', fg: '#991b1b' },
};

const emptyEditForm = {
  avatar: null,
  avatarPreview: null,
  idCardImage: null,
  idCardPreview: null,
  name_ar: '',
  phone: '',
  email: '',
  address: '',
  city: '',
  governorate: '',
  is_verified: false,
  is_featured: false,
  is_available: true,
};

const Workers = () => {
  const navigate = useNavigate();
  const [search, setSearch] = useState('');
  const [profileFilter, setProfileFilter] = useState('');
  const [verificationFilter, setVerificationFilter] = useState('');
  const [selectedWorker, setSelectedWorker] = useState(null);
  const [editingWorker, setEditingWorker] = useState(null);
  const [editForm, setEditForm] = useState(emptyEditForm);
  const [editLoading, setEditLoading] = useState(false);
  const [editError, setEditError] = useState(null);

  const [rejectWorker, setRejectWorker] = useState(null);
  const [rejectReason, setRejectReason] = useState('');
  const [rejectLoading, setRejectLoading] = useState(false);

  const [verifyLoading, setVerifyLoading] = useState(false);

  const debouncedSearch = useDebouncedValue(search, 300);

  const fetchWorkers = useCallback(async () => {
    const params = { page_size: 50 };
    if (debouncedSearch) params.search = debouncedSearch;
    if (profileFilter) params.status = profileFilter;
    if (verificationFilter) params.verification = verificationFilter;
    const res = await adminAPI.workers.list(params);
    return res.data;
  }, [debouncedSearch, profileFilter, verificationFilter]);

  const { data, loading, error, lastUpdatedAt, refresh } =
    usePolling(fetchWorkers, { intervalMs: 4_000, initialData: { results: [], count: 0, complete_count: 0, incomplete_count: 0, pending_count: 0, verified_count: 0, rejected_count: 0 } });
  const workers = data?.results || [];
  const total = data?.count || 0;
  const completeCount = data?.complete_count || 0;
  const incompleteCount = data?.incomplete_count || 0;
  const pendingCount = data?.pending_count || 0;
  const verifiedCount = data?.verified_count || 0;
  const rejectedCount = data?.rejected_count || 0;
  const updatedLabel = useTimeAgo(lastUpdatedAt);

  const viewDetail = async (worker) => {
    try {
      const res = await adminAPI.workers.detail(worker.user?.id);
      setSelectedWorker(res.data);
    } catch {
      alert('Failed to load worker details');
    }
  };

  const openEdit = (worker) => {
    setEditingWorker(worker);
    setEditForm({
      avatar: null,
      avatarPreview: worker.user?.avatar_url || null,
      idCardImage: null,
      idCardPreview: worker.user?.id_card_url || null,
      name_ar: worker.user?.name_ar || '',
      phone: worker.user?.phone || '',
      email: worker.user?.email || '',
      address: worker.user?.address || '',
      city: worker.user?.city || '',
      governorate: worker.user?.governorate || '',
      is_verified: !!worker.is_verified,
      is_featured: !!worker.is_featured,
      is_available: !!worker.is_available,
    });
    setEditError(null);
  };

  const submitEdit = async (e) => {
    e.preventDefault();
    if (!editingWorker) return;
    setEditLoading(true);
    setEditError(null);
    try {
      const hasFile = editForm.avatar instanceof File || editForm.idCardImage instanceof File;
      let payload;
      if (hasFile) {
        const fd = new FormData();
        if (editForm.avatar instanceof File) fd.append('avatar', editForm.avatar);
        if (editForm.idCardImage instanceof File) fd.append('id_card_image', editForm.idCardImage);
        fd.append('name_ar', editForm.name_ar);
        fd.append('phone', editForm.phone);
        fd.append('email', editForm.email);
        fd.append('address', editForm.address);
        fd.append('city', editForm.city);
        fd.append('governorate', editForm.governorate);
        fd.append('is_verified', editForm.is_verified ? 'true' : 'false');
        fd.append('is_featured', editForm.is_featured ? 'true' : 'false');
        fd.append('is_available', editForm.is_available ? 'true' : 'false');
        payload = fd;
      } else {
        payload = {
          name_ar: editForm.name_ar,
          phone: editForm.phone,
          email: editForm.email,
          address: editForm.address,
          city: editForm.city,
          governorate: editForm.governorate,
          is_verified: editForm.is_verified,
          is_featured: editForm.is_featured,
          is_available: editForm.is_available,
        };
      }
      await adminAPI.workers.update(editingWorker.user?.id, payload);
      setEditingWorker(null);
      refresh();
    } catch (err) {
      const d = err.response?.data;
      if (d && typeof d === 'object') {
        const lines = [];
        for (const [k, msgs] of Object.entries(d)) {
          const arr = Array.isArray(msgs) ? msgs : [msgs];
          arr.forEach((m) => lines.push(`${k}: ${m}`));
        }
        setEditError(lines.join('\n') || 'Update failed.');
      } else {
        setEditError(err.message || 'Update failed.');
      }
    } finally {
      setEditLoading(false);
    }
  };

  const handleVerify = async (worker) => {
    if (!window.confirm(`Verify ${worker.user?.display_name || worker.user?.username}?`)) return;
    setVerifyLoading(true);
    try {
      await adminAPI.workers.verify(worker.user?.id);
      refresh();
    } catch (err) {
      alert('Failed to verify worker: ' + (err.response?.data?.error || err.message));
    } finally {
      setVerifyLoading(false);
    }
  };

  const handleReject = async () => {
    if (!rejectWorker) return;
    setRejectLoading(true);
    try {
      await adminAPI.workers.reject(rejectWorker.user?.id, rejectReason);
      setRejectWorker(null);
      setRejectReason('');
      refresh();
    } catch (err) {
      alert('Failed to reject worker: ' + (err.response?.data?.error || err.message));
    } finally {
      setRejectLoading(false);
    }
  };

  const columns = [
    {
      key: 'user',
      label: 'Worker',
      render: (row) => (
        <div className="d-flex align-items-center gap-2">
          <div className="rounded-circle d-flex align-items-center justify-content-center overflow-hidden" style={{ width: '36px', height: '36px', backgroundColor: '#f59e0b15', color: '#f59e0b', fontSize: '14px', fontWeight: '700' }}>
            {row.user?.avatar_url ? (
              <img src={row.user.avatar_url} alt="" style={{ width: '100%', height: '100%', objectFit: 'cover' }} />
            ) : (
              row.user?.username?.[0]?.toUpperCase() || '?'
            )}
          </div>
          <div>
            <div style={{ fontWeight: 600, color: '#1e293b' }}>
              {row.user?.display_name || row.user?.username || 'N/A'}
            </div>
            <div className="text-muted" style={{ fontSize: '12px' }}>
              {row.user?.phone || '—'}
            </div>
          </div>
        </div>
      ),
    },
    {
      key: 'profession',
      label: 'Profession',
      render: (row) => row.has_profile
        ? (
          <div>
            <div style={{ fontWeight: 500 }}>{row.profession || '—'}</div>
            {row.profession_ar ? (
              <div className="text-muted" style={{ fontSize: '12px' }}>{row.profession_ar}</div>
            ) : null}
          </div>
        )
        : <span className="badge rounded-pill" style={{ backgroundColor: '#fef3c7', color: '#92400e' }}>Not set up</span>,
    },
    {
      key: 'verification_status',
      label: 'Verification',
      render: (row) => {
        const vs = row.user?.verification_status || 'verified';
        const c = VERIFICATION_COLORS[vs] || VERIFICATION_COLORS.verified;
        return (
          <span className="badge rounded-pill px-3 py-1" style={{ backgroundColor: c.bg, color: c.fg }}>
            {vs === 'verified' && <i className="bi bi-patch-check-fill me-1"></i>}
            {vs === 'pending' && <i className="bi bi-hourglass-split me-1"></i>}
            {vs === 'rejected' && <i className="bi bi-x-circle-fill me-1"></i>}
            {VERIFICATION_LABELS[vs] || vs}
          </span>
        );
      },
    },
    {
      key: 'has_profile',
      label: 'Onboarding',
      render: (row) => row.has_profile
        ? <span className="badge rounded-pill" style={{ backgroundColor: '#dcfce7', color: '#166534' }}>Complete</span>
        : <span className="badge rounded-pill" style={{ backgroundColor: '#f3f4f6', color: '#6b7280' }}>Incomplete</span>,
    },
    {
      key: 'average_rating',
      label: 'Rating',
      render: (row) => row.has_profile
        ? (
          <span>
            {(row.average_rating || 0).toFixed(1)}
            <i className="bi bi-star-fill ms-1" style={{ color: '#f59e0b', fontSize: '12px' }}></i>
          </span>
        )
        : <span className="text-muted">—</span>,
    },
    {
      key: 'completed_jobs',
      label: 'Jobs',
      render: (row) => row.has_profile
        ? <span>{row.completed_jobs}</span>
        : <span className="text-muted">—</span>,
    },
    {
      key: 'delay_cancellations',
      label: 'Incidents',
      render: (row) => {
        const n = row.delay_cancellations || 0;
        if (n === 0) return <span className="text-muted">—</span>;
        const repeated = n >= 2;
        return (
          <span className="badge rounded-pill px-2 py-1" style={{ backgroundColor: repeated ? '#ef444410' : '#f9731610', color: repeated ? '#dc2626' : '#ea580c', fontSize: '12px' }} title={repeated ? 'Multiple cancellations caused by this worker being late' : 'One cancellation caused by worker delay'}>
            <i className={`bi ${repeated ? 'bi-exclamation-triangle-fill' : 'bi-clock-history'} me-1`}></i>
            {n} delay{repeated ? ' · repeated' : ''}
          </span>
        );
      },
    },
    {
      key: 'actions',
      label: '',
      render: (row) => {
        const vs = row.user?.verification_status;
        return (
          <div className="d-flex gap-1 flex-wrap">
            {vs === 'pending' && (
              <>
                <button
                  className="btn btn-sm"
                  style={{ color: '#166534', background: '#dcfce7', borderRadius: '8px' }}
                  onClick={() => handleVerify(row)}
                  title="Verify worker"
                  disabled={verifyLoading}
                >
                  <i className="bi bi-check-lg"></i>
                </button>
                <button
                  className="btn btn-sm"
                  style={{ color: '#991b1b', background: '#fee2e2', borderRadius: '8px' }}
                  onClick={() => { setRejectWorker(row); setRejectReason(''); }}
                  title="Reject worker"
                >
                  <i className="bi bi-x-lg"></i>
                </button>
              </>
            )}
            <button
              className="btn btn-sm"
              style={{ color: '#6366f1', background: '#6366f110', borderRadius: '8px' }}
              onClick={() => viewDetail(row)}
              title="View details"
            >
              <i className="bi bi-eye"></i>
            </button>
            <button
              className="btn btn-sm"
              style={{ color: '#f59e0b', background: '#f59e0b15', borderRadius: '8px' }}
              onClick={() => openEdit(row)}
              title="Edit worker"
            >
              <i className="bi bi-pencil"></i>
            </button>
          </div>
        );
      },
    },
  ];

  return (
    <div>
      <div className="page-header d-flex justify-content-between align-items-center flex-wrap gap-2">
        <div>
          <h4 className="mb-1">Workers Management</h4>
          <p className="mb-0">View all registered workers, manage verification and details.</p>
        </div>
        <div className="d-flex align-items-center gap-2">
          <span className="text-muted small">
            <i className="bi bi-arrow-clockwise me-1"></i>
            {updatedLabel ? `Updated ${updatedLabel}` : 'Loading…'}
          </span>
          <button type="button" className="btn btn-sm btn-outline-secondary" onClick={refresh} disabled={loading} title="Refresh now">
            <i className="bi bi-arrow-repeat"></i>
          </button>
          <ExportCsvButton fetcher={adminAPI.exports.workers} filename="workers.csv" />
        </div>
      </div>

      {/* Pending verification banner */}
      {pendingCount > 0 && (
        <div className="card border-0 mb-3" style={{ borderRadius: '15px', background: 'linear-gradient(135deg, #fff7ed 0%, #fef3c7 100%)' }}>
          <div className="card-body p-3 p-md-4">
            <div className="d-flex flex-wrap align-items-center gap-3">
              <div className="rounded-circle d-flex align-items-center justify-content-center" style={{ width: '52px', height: '52px', backgroundColor: '#f59e0b25', color: '#b45309' }}>
                <i className="bi bi-person-exclamation fs-3"></i>
              </div>
              <div className="flex-grow-1">
                <div className="fw-bold" style={{ color: '#92400e', fontSize: '15px' }}>
                  {pendingCount} worker{pendingCount !== 1 ? 's' : ''} pending verification
                </div>
                <div style={{ color: '#92400e', fontSize: '13px', opacity: 0.85 }}>
                  Workers waiting for admin approval. Review their details and verify or reject their accounts.
                </div>
                <div className="mt-2 d-flex align-items-center gap-3" style={{ fontSize: '12px', color: '#92400e' }}>
                  <span><strong>{verifiedCount}</strong> verified</span>
                  <span><strong>{pendingCount}</strong> pending</span>
                  <span><strong>{rejectedCount}</strong> rejected</span>
                </div>
              </div>
              <button
                className="btn btn-sm"
                style={{ background: '#92400e', color: 'white', borderRadius: '8px', padding: '6px 14px' }}
                onClick={() => setVerificationFilter('pending')}
              >
                Show pending
              </button>
            </div>
          </div>
        </div>
      )}

      {error && (
        <div className="alert alert-danger d-flex align-items-center gap-2 mb-3" style={{ borderRadius: '12px', border: 'none' }}>
          <i className="bi bi-exclamation-triangle-fill"></i>
          <div>
            <strong>Failed to load workers.</strong>{' '}
            {error?.response?.status === 401 && 'Session expired — try refreshing.'}
            {error?.response?.status === 403 && 'You do not have admin permissions.'}
            {![401, 403].includes(error?.response?.status) && (error?.response?.data?.detail || error?.message || 'Unknown error')}
          </div>
        </div>
      )}

      <div className="card border-0 shadow-sm" style={{ borderRadius: '15px' }}>
        <div className="card-body p-4">
          <div className="row mb-3 g-2">
            <div className="col-md-4">
              <div className="input-group" style={{ borderRadius: '10px', overflow: 'hidden' }}>
                <span className="input-group-text bg-white border-end-0"><i className="bi bi-search text-muted"></i></span>
                <input type="text" className="form-control border-start-0" placeholder="Search workers by name, phone or email..."
                  value={search} onChange={(e) => setSearch(e.target.value)}
                  style={{ padding: '10px 14px' }} />
              </div>
            </div>
            <div className="col-md-3">
              <select className="form-select" value={profileFilter} onChange={(e) => setProfileFilter(e.target.value)} style={{ padding: '10px 15px', borderRadius: '10px' }}>
                <option value="">All onboarding</option>
                <option value="complete">Onboarded ({completeCount})</option>
                <option value="incomplete">Incomplete ({incompleteCount})</option>
              </select>
            </div>
            <div className="col-md-3">
              <select className="form-select" value={verificationFilter} onChange={(e) => setVerificationFilter(e.target.value)} style={{ padding: '10px 15px', borderRadius: '10px' }}>
                <option value="">All verification</option>
                <option value="verified">Verified ({verifiedCount})</option>
                <option value="pending">Pending ({pendingCount})</option>
                <option value="rejected">Rejected ({rejectedCount})</option>
              </select>
            </div>
            <div className="col-md-2 text-md-end small text-muted d-flex align-items-center justify-content-md-end">
              <span>Showing {workers.length} of {total}</span>
            </div>
          </div>
          <Table columns={columns} data={workers} loading={loading} emptyMessage="No workers match the current filter" onRowClick={(row) => row.user?.id && navigate(`/admin/workers/${row.user.id}`)} />
        </div>
      </div>

      {/* Worker Detail Modal */}
      {selectedWorker && (
        <div className="modal d-block" tabIndex="-1" style={{ backgroundColor: 'rgba(0,0,0,0.5)' }}>
          <div className="modal-dialog modal-dialog-centered modal-lg">
            <div className="modal-content" style={{ borderRadius: '15px', border: 'none' }}>
              <div className="modal-header border-0">
                <h5 className="modal-title fw-bold">Worker Details</h5>
                <button type="button" className="btn-close" onClick={() => setSelectedWorker(null)}></button>
              </div>
              <div className="modal-body pt-0">
                {/* Header */}
                <div className="text-center mb-4">
                  <div className="rounded-circle d-flex align-items-center justify-content-center mx-auto mb-2 overflow-hidden" style={{ width: '80px', height: '80px', backgroundColor: '#f59e0b20', color: '#f59e0b', fontSize: '28px', fontWeight: '700' }}>
                    {selectedWorker.user?.avatar_url ? (
                      <img src={selectedWorker.user.avatar_url} alt="" style={{ width: '100%', height: '100%', objectFit: 'cover' }} />
                    ) : (
                      selectedWorker.user?.username?.[0]?.toUpperCase() || '?'
                    )}
                  </div>
                  <h5 className="fw-bold mb-0">{selectedWorker.user?.display_name || selectedWorker.user?.username}</h5>
                  <span className="text-muted" style={{ fontSize: '13px' }}>{selectedWorker.user?.email || '—'}</span>
                  <div className="mt-1">
                    {(() => {
                      const vs = selectedWorker.user?.verification_status || 'verified';
                      const c = VERIFICATION_COLORS[vs] || VERIFICATION_COLORS.verified;
                      return (
                        <span className="badge rounded-pill px-3 py-1" style={{ backgroundColor: c.bg, color: c.fg }}>
                          {vs === 'verified' && <i className="bi bi-patch-check-fill me-1"></i>}
                          {vs === 'pending' && <i className="bi bi-hourglass-split me-1"></i>}
                          {vs === 'rejected' && <i className="bi bi-x-circle-fill me-1"></i>}
                          {VERIFICATION_LABELS[vs] || vs}
                        </span>
                      );
                    })()}
                  </div>
                </div>

                {/* Registration info */}
                <div className="row g-3">
                  <div className="col-md-6">
                    <div className="p-3 rounded-3" style={{ backgroundColor: '#f8fafc' }}>
                      <p className="text-muted mb-0" style={{ fontSize: '12px' }}>Full Name (Arabic)</p>
                      <p className="fw-bold mb-0" style={{ fontSize: '14px' }}>{selectedWorker.user?.name_ar || '—'}</p>
                    </div>
                  </div>
                  <div className="col-md-6">
                    <div className="p-3 rounded-3" style={{ backgroundColor: '#f8fafc' }}>
                      <p className="text-muted mb-0" style={{ fontSize: '12px' }}>Phone</p>
                      <p className="fw-bold mb-0" style={{ fontSize: '14px' }}>{selectedWorker.user?.phone || '—'}</p>
                    </div>
                  </div>
                  <div className="col-md-6">
                    <div className="p-3 rounded-3" style={{ backgroundColor: '#f8fafc' }}>
                      <p className="text-muted mb-0" style={{ fontSize: '12px' }}>Governorate</p>
                      <p className="fw-bold mb-0" style={{ fontSize: '14px' }}>{selectedWorker.user?.governorate_label || selectedWorker.user?.governorate || '—'}</p>
                    </div>
                  </div>
                  <div className="col-md-6">
                    <div className="p-3 rounded-3" style={{ backgroundColor: '#f8fafc' }}>
                      <p className="text-muted mb-0" style={{ fontSize: '12px' }}>City</p>
                      <p className="fw-bold mb-0" style={{ fontSize: '14px' }}>{selectedWorker.user?.city || '—'}</p>
                    </div>
                  </div>
                  <div className="col-md-6">
                    <div className="p-3 rounded-3" style={{ backgroundColor: '#f8fafc' }}>
                      <p className="text-muted mb-0" style={{ fontSize: '12px' }}>Registered</p>
                      <p className="fw-bold mb-0" style={{ fontSize: '14px' }}>{selectedWorker.user?.date_joined ? new Date(selectedWorker.user.date_joined).toLocaleDateString() : '—'}</p>
                    </div>
                  </div>
                  {selectedWorker.user?.verified_at && (
                    <div className="col-md-6">
                      <div className="p-3 rounded-3" style={{ backgroundColor: '#f8fafc' }}>
                        <p className="text-muted mb-0" style={{ fontSize: '12px' }}>Verified At</p>
                        <p className="fw-bold mb-0" style={{ fontSize: '14px' }}>{new Date(selectedWorker.user.verified_at).toLocaleString()}</p>
                      </div>
                    </div>
                  )}
                </div>

                {/* Rejection reason */}
                {selectedWorker.user?.verification_status === 'rejected' && selectedWorker.user?.rejection_reason && (
                  <div className="mt-3 p-3 rounded-3" style={{ backgroundColor: '#fee2e2', border: '1px solid #fecaca' }}>
                    <p className="fw-bold mb-1" style={{ fontSize: '13px', color: '#991b1b' }}>Rejection Reason:</p>
                    <p className="mb-0" style={{ fontSize: '14px', color: '#991b1b' }}>{selectedWorker.user.rejection_reason}</p>
                  </div>
                )}

                {/* Profile photo */}
                {selectedWorker.user?.avatar_url && (
                  <div className="mt-3">
                    <p className="text-muted mb-2" style={{ fontSize: '12px' }}>Profile Photo</p>
                    <img src={selectedWorker.user.avatar_url} alt="Profile" style={{ maxWidth: '120px', borderRadius: '12px', border: '2px solid #e2e8f0' }} />
                  </div>
                )}

                {/* ID Card Image */}
                {selectedWorker.user?.id_card_url && (
                  <div className="mt-3">
                    <p className="text-muted mb-2" style={{ fontSize: '12px' }}>ID Card</p>
                    <img src={selectedWorker.user.id_card_url} alt="ID Card" style={{ maxWidth: '300px', borderRadius: '12px', border: '2px solid #e2e8f0' }} />
                  </div>
                )}
              </div>
              <div className="modal-footer border-0 pt-0 d-flex gap-2">
                {selectedWorker.user?.verification_status === 'pending' && (
                  <>
                    <button
                      className="btn px-3 text-white"
                      style={{ borderRadius: '10px', background: '#166534', border: 'none' }}
                      onClick={async () => {
                        try {
                          await adminAPI.workers.verify(selectedWorker.user?.id);
                          setSelectedWorker(null);
                          refresh();
                        } catch (err) {
                          alert('Failed: ' + (err.response?.data?.error || err.message));
                        }
                      }}
                    >
                      <i className="bi bi-check-lg me-1"></i>Verify Worker
                    </button>
                    <button
                      className="btn px-3"
                      style={{ borderRadius: '10px', background: '#991b1b', color: 'white', border: 'none' }}
                      onClick={() => { setRejectWorker({ user: { id: selectedWorker.user?.id } }); setRejectReason(''); setSelectedWorker(null); }}
                    >
                      <i className="bi bi-x-lg me-1"></i>Reject Worker
                    </button>
                  </>
                )}
                <button className="btn px-4" style={{ borderRadius: '10px', border: '1px solid #e2e8f0', color: '#475569' }} onClick={() => setSelectedWorker(null)}>Close</button>
              </div>
            </div>
          </div>
        </div>
      )}

      {/* Worker Edit Modal */}
      {editingWorker && (
        <div className="modal d-block" tabIndex="-1" style={{ backgroundColor: 'rgba(0,0,0,0.5)' }}>
          <div className="modal-dialog modal-dialog-centered">
            <div className="modal-content" style={{ borderRadius: '15px', border: 'none' }}>
              <div className="modal-header border-0">
                <h5 className="modal-title fw-bold">
                  Edit {editingWorker.user?.display_name || editingWorker.user?.username || 'worker'}
                </h5>
                <button type="button" className="btn-close" onClick={() => setEditingWorker(null)}></button>
              </div>
              <form onSubmit={submitEdit}>
                <div className="modal-body pt-0">
                  {editError && (
                    <div className="alert alert-danger py-2 px-3" style={{ borderRadius: '10px', fontSize: '13px', border: 'none' }}>
                      <i className="bi bi-exclamation-circle me-1"></i>
                      {editError.split('\n').map((line, i) => <div key={i}>{line}</div>)}
                    </div>
                  )}

                  {/* Profile picture upload */}
                  <div className="mb-3 d-flex align-items-center gap-3">
                    <div style={{
                      width: 72, height: 72, borderRadius: '50%',
                      background: '#f1f5f9', overflow: 'hidden',
                      display: 'flex', alignItems: 'center',
                      justifyContent: 'center', color: '#94a3b8',
                      fontWeight: 700, fontSize: 26, flexShrink: 0,
                    }}>
                      {editForm.avatar instanceof File ? (
                        <img alt="" src={URL.createObjectURL(editForm.avatar)}
                             style={{ width: '100%', height: '100%', objectFit: 'cover' }} />
                      ) : editForm.avatarPreview ? (
                        <img alt="" src={editForm.avatarPreview}
                             style={{ width: '100%', height: '100%', objectFit: 'cover' }} />
                      ) : (
                        (editingWorker.user?.username?.[0] || '?').toUpperCase()
                      )}
                    </div>
                    <div className="flex-grow-1">
                      <label className="form-label mb-1" style={{ fontSize: '13px', fontWeight: 500 }}>
                        Profile picture
                      </label>
                      <input
                        className="form-control"
                        type="file"
                        accept="image/*"
                        onChange={(e) => setEditForm({ ...editForm, avatar: e.target.files[0] || null })}
                        style={{ borderRadius: '10px' }}
                      />
                      {editForm.avatar instanceof File && (
                        <button type="button" className="btn btn-link btn-sm p-0 mt-1" style={{ fontSize: 12 }}
                                onClick={() => setEditForm({ ...editForm, avatar: null })}>
                          Cancel selection
                        </button>
                      )}
                    </div>
                  </div>

                  {/* ID Card upload */}
                  <div className="mb-3">
                    <label className="form-label mb-1" style={{ fontSize: '13px', fontWeight: 500 }}>
                      <i className="bi bi-credit-card me-1"></i> ID Card Image
                    </label>
                    {editForm.idCardPreview && !editForm.idCardImage && (
                      <div className="mb-2">
                        <img src={editForm.idCardPreview} alt="ID Card" style={{ maxWidth: '200px', borderRadius: '8px', border: '1px solid #e2e8f0' }} />
                      </div>
                    )}
                    {editForm.idCardImage && (
                      <div className="mb-2">
                        <img src={URL.createObjectURL(editForm.idCardImage)} alt="ID Card" style={{ maxWidth: '200px', borderRadius: '8px', border: '1px solid #e2e8f0' }} />
                        <button type="button" className="btn btn-link btn-sm p-0 ms-2" style={{ fontSize: 12 }}
                                onClick={() => setEditForm({ ...editForm, idCardImage: null, idCardPreview: editingWorker.user?.id_card_url || null })}>
                          Cancel selection
                        </button>
                      </div>
                    )}
                    <input
                      className="form-control"
                      type="file"
                      accept="image/*"
                      onChange={(e) => setEditForm({ ...editForm, idCardImage: e.target.files[0] || null })}
                      style={{ borderRadius: '10px' }}
                    />
                  </div>

                  {/* Text fields */}
                  <div className="mb-2">
                    <label className="form-label" style={{ fontSize: '13px' }}>Name (Arabic)</label>
                    <input className="form-control" value={editForm.name_ar} onChange={(e) => setEditForm({ ...editForm, name_ar: e.target.value })} style={{ borderRadius: '10px' }} />
                  </div>
                  <div className="row g-2 mb-2">
                    <div className="col-6">
                      <label className="form-label" style={{ fontSize: '13px' }}>Phone</label>
                      <input className="form-control" value={editForm.phone} onChange={(e) => setEditForm({ ...editForm, phone: e.target.value })} style={{ borderRadius: '10px' }} />
                    </div>
                    <div className="col-6">
                      <label className="form-label" style={{ fontSize: '13px' }}>Email</label>
                      <input className="form-control" value={editForm.email} onChange={(e) => setEditForm({ ...editForm, email: e.target.value })} style={{ borderRadius: '10px' }} />
                    </div>
                  </div>
                  <div className="row g-2 mb-2">
                    <div className="col-6">
                      <label className="form-label" style={{ fontSize: '13px' }}>Governorate</label>
                      <input className="form-control" value={editForm.governorate} onChange={(e) => setEditForm({ ...editForm, governorate: e.target.value })} style={{ borderRadius: '10px' }} />
                    </div>
                    <div className="col-6">
                      <label className="form-label" style={{ fontSize: '13px' }}>City</label>
                      <input className="form-control" value={editForm.city} onChange={(e) => setEditForm({ ...editForm, city: e.target.value })} style={{ borderRadius: '10px' }} />
                    </div>
                  </div>

                  {/* Toggles */}
                  <hr className="my-3" />
                  <div className="form-check form-switch mb-2">
                    <input className="form-check-input" type="checkbox" id="workerVerified"
                           checked={editForm.is_verified}
                           onChange={(e) => setEditForm({ ...editForm, is_verified: e.target.checked })} />
                    <label className="form-check-label" htmlFor="workerVerified" style={{ fontSize: '14px' }}>
                      <i className="bi bi-patch-check-fill me-1" style={{ color: '#1d4ed8' }}></i>
                      Verified worker
                    </label>
                  </div>
                  <div className="form-check form-switch mb-2">
                    <input className="form-check-input" type="checkbox" id="workerFeatured"
                           checked={editForm.is_featured}
                           onChange={(e) => setEditForm({ ...editForm, is_featured: e.target.checked })} />
                    <label className="form-check-label" htmlFor="workerFeatured" style={{ fontSize: '14px' }}>
                      <i className="bi bi-star-fill me-1" style={{ color: '#f59e0b' }}></i>
                      Featured on the homepage
                    </label>
                  </div>
                  <div className="form-check form-switch">
                    <input className="form-check-input" type="checkbox" id="workerAvailable"
                           checked={editForm.is_available}
                           onChange={(e) => setEditForm({ ...editForm, is_available: e.target.checked })} />
                    <label className="form-check-label" htmlFor="workerAvailable" style={{ fontSize: '14px' }}>
                      <i className="bi bi-circle-fill me-1" style={{ color: '#10b981', fontSize: '10px' }}></i>
                      Available for orders
                    </label>
                  </div>
                </div>
                <div className="modal-footer border-0 pt-0">
                  <button type="button" className="btn px-4"
                          style={{ borderRadius: '10px', border: '1px solid #e2e8f0', color: '#475569' }}
                          onClick={() => setEditingWorker(null)}>Cancel</button>
                  <button type="submit" className="btn px-4 text-white"
                          style={{ borderRadius: '10px', background: '#f59e0b', border: 'none' }}
                          disabled={editLoading}>
                    {editLoading ? <span className="spinner-border spinner-border-sm me-2"></span> : null}
                    Save changes
                  </button>
                </div>
              </form>
            </div>
          </div>
        </div>
      )}

      {/* Reject Worker Modal */}
      {rejectWorker && (
        <div className="modal d-block" tabIndex="-1" style={{ backgroundColor: 'rgba(0,0,0,0.5)' }}>
          <div className="modal-dialog modal-dialog-centered">
            <div className="modal-content" style={{ borderRadius: '15px', border: 'none' }}>
              <div className="modal-header border-0">
                <h5 className="modal-title fw-bold" style={{ color: '#991b1b' }}>
                  <i className="bi bi-x-circle me-2"></i>Reject Worker
                </h5>
                <button type="button" className="btn-close" onClick={() => setRejectWorker(null)}></button>
              </div>
              <div className="modal-body pt-0">
                <p className="text-muted mb-3">
                  Are you sure you want to reject <strong>{rejectWorker.user?.display_name || rejectWorker.user?.username}</strong>?
                </p>
                <label className="form-label" style={{ fontSize: '13px', fontWeight: 500 }}>Reason for rejection (optional)</label>
                <textarea
                  className="form-control"
                  rows={3}
                  value={rejectReason}
                  onChange={(e) => setRejectReason(e.target.value)}
                  placeholder="Explain why this worker is being rejected..."
                  style={{ borderRadius: '10px' }}
                ></textarea>
              </div>
              <div className="modal-footer border-0 pt-0">
                <button type="button" className="btn px-4"
                        style={{ borderRadius: '10px', border: '1px solid #e2e8f0', color: '#475569' }}
                        onClick={() => setRejectWorker(null)}>Cancel</button>
                <button type="button" className="btn px-4 text-white"
                        style={{ borderRadius: '10px', background: '#991b1b', border: 'none' }}
                        onClick={handleReject} disabled={rejectLoading}>
                  {rejectLoading ? <span className="spinner-border spinner-border-sm me-2"></span> : null}
                  Reject Worker
                </button>
              </div>
            </div>
          </div>
        </div>
      )}
    </div>
  );
};

export default Workers;
