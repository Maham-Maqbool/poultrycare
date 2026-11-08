"""
SQLAlchemy Schema Models for PoultryCare.
Implements the 10 relational tables and 7 enumerated types specified in Chapter 5.
"""

import uuid
from datetime import datetime, timezone
from sqlalchemy import (
    Column,
    String,
    Text,
    Boolean,
    Integer,
    SmallInteger,
    Float,
    DateTime,
    ForeignKey,
    Enum,
    JSON,
    Index,
    UniqueConstraint,
)
from sqlalchemy.orm import relationship
from backend.db import Base

# ==============================================================================
# Chapter 5 Enumerated Types (Table 5.5)
# ==============================================================================

DISEASE_CLASSES = ("coccidiosis", "healthy", "ncd", "salmonella")
SEVERITY_LEVELS = ("mild", "moderate", "severe")
URGENCY_LEVELS = ("monitor", "treat_today", "vet_soon", "vet_now")
CERTAINTY_LEVELS = ("confident", "uncertain", "cannot_tell")
LOCALES = ("en", "ur")
USER_ROLES = ("farmer", "admin")
ABSTAIN_REASONS = (
    "quality",
    "out_of_distribution",
    "low_confidence",
    "ambiguous",
    "no_class_plausible",
)


def utcnow():
    """Returns current UTC timestamp with timezone."""
    return datetime.now(timezone.utc)


def new_uuid():
    """Generates standard UUID4 string."""
    return str(uuid.uuid4())


# ==============================================================================
# 1. Users Table (Chapter 5, Table 5.6)
# ==============================================================================
class User(Base):
    __tablename__ = "users"

    id = Column(String(36), primary_key=True, default=new_uuid)
    email = Column(String(320), unique=True, nullable=True)
    phone = Column(String(32), unique=True, nullable=True)
    password_hash = Column(Text, nullable=True)
    display_name = Column(String(120), nullable=True)
    locale = Column(
        Enum(*LOCALES, name="locale", native_enum=False),
        nullable=False,
        default="en",
    )
    role = Column(
        Enum(*USER_ROLES, name="user_role", native_enum=False),
        nullable=False,
        default="farmer",
    )
    consent_to_retain_images = Column(Boolean, nullable=False, default=False)
    created_at = Column(DateTime(timezone=True), nullable=False, default=utcnow)
    last_seen_at = Column(DateTime(timezone=True), nullable=True)

    # Relationships
    sessions = relationship("Session", back_populates="user", cascade="all, delete-orphan")
    flocks = relationship("Flock", back_populates="user", cascade="all, delete-orphan")
    scans = relationship("Scan", back_populates="user")

    __table_args__ = (
        Index("users_identity_idx", "email", "phone"),
    )


# ==============================================================================
# 2. Sessions Table (Chapter 5, Table 5.7)
# ==============================================================================
class Session(Base):
    __tablename__ = "sessions"

    id = Column(String(36), primary_key=True, default=new_uuid)
    user_id = Column(
        String(36),
        ForeignKey("users.id", ondelete="CASCADE"),
        nullable=False,
    )
    token_hash = Column(Text, unique=True, nullable=False)
    expires_at = Column(DateTime(timezone=True), nullable=False)
    created_at = Column(DateTime(timezone=True), nullable=False, default=utcnow)

    # Relationships
    user = relationship("User", back_populates="sessions")

    __table_args__ = (
        Index("sessions_user_idx", "user_id"),
    )


# ==============================================================================
# 3. Flocks Table (Chapter 5, Table 5.8)
# ==============================================================================
class Flock(Base):
    __tablename__ = "flocks"

    id = Column(String(36), primary_key=True, default=new_uuid)
    user_id = Column(
        String(36),
        ForeignKey("users.id", ondelete="CASCADE"),
        nullable=False,
    )
    name = Column(String(120), nullable=False)
    bird_count = Column(Integer, nullable=True)
    breed = Column(String(120), nullable=True)
    notes = Column(Text, nullable=True)
    created_at = Column(DateTime(timezone=True), nullable=False, default=utcnow)

    # Relationships
    user = relationship("User", back_populates="flocks")
    scans = relationship("Scan", back_populates="flock")

    __table_args__ = (
        Index("flocks_user_idx", "user_id"),
    )


# ==============================================================================
# 4. Diseases Table (Chapter 5, Table 5.9)
# ==============================================================================
class Disease(Base):
    __tablename__ = "diseases"

    code = Column(
        Enum(*DISEASE_CLASSES, name="disease_class", native_enum=False),
        primary_key=True,
    )
    name_en = Column(String(120), nullable=False)
    name_ur = Column(String(120), nullable=False)
    summary_en = Column(Text, nullable=False)
    summary_ur = Column(Text, nullable=False)
    signs_en = Column(JSON, nullable=False, default=list)
    signs_ur = Column(JSON, nullable=False, default=list)
    baseline_severity = Column(
        Enum(*SEVERITY_LEVELS, name="severity", native_enum=False),
        nullable=False,
    )
    baseline_urgency = Column(
        Enum(*URGENCY_LEVELS, name="urgency", native_enum=False),
        nullable=False,
    )
    is_notifiable = Column(Boolean, nullable=False, default=False)
    audio_en = Column(String(255), nullable=True)
    audio_ur = Column(String(255), nullable=True)
    display_order = Column(SmallInteger, nullable=False, default=0)

    # Relationships
    treatments = relationship("Treatment", back_populates="disease", cascade="all, delete-orphan")


# ==============================================================================
# 5. Treatments Table (Chapter 5, Table 5.10)
# ==============================================================================
class Treatment(Base):
    __tablename__ = "treatments"

    id = Column(String(36), primary_key=True, default=new_uuid)
    disease_code = Column(
        Enum(*DISEASE_CLASSES, name="disease_class", native_enum=False),
        ForeignKey("diseases.code", ondelete="CASCADE"),
        nullable=False,
    )
    severity = Column(
        Enum(*SEVERITY_LEVELS, name="severity", native_enum=False),
        nullable=False,
    )
    medicines_en = Column(JSON, nullable=False, default=list)
    medicines_ur = Column(JSON, nullable=False, default=list)
    care_steps_en = Column(JSON, nullable=False, default=list)
    care_steps_ur = Column(JSON, nullable=False, default=list)
    biosecurity_en = Column(JSON, nullable=False, default=list)
    biosecurity_ur = Column(JSON, nullable=False, default=list)
    vet_required = Column(Boolean, nullable=False, default=False)
    urgency = Column(
        Enum(*URGENCY_LEVELS, name="urgency", native_enum=False),
        nullable=False,
    )
    version = Column(Integer, nullable=False, default=1)
    reviewed_by = Column(String(160), nullable=True)
    reviewed_at = Column(DateTime(timezone=True), nullable=True)
    audio_en = Column(String(255), nullable=True)
    audio_ur = Column(String(255), nullable=True)
    created_at = Column(DateTime(timezone=True), nullable=False, default=utcnow)
    updated_at = Column(DateTime(timezone=True), nullable=False, default=utcnow, onupdate=utcnow)

    # Relationships
    disease = relationship("Disease", back_populates="treatments")

    __table_args__ = (
        UniqueConstraint("disease_code", "severity", name="treatments_disease_severity_idx"),
    )


# ==============================================================================
# 6. Model Versions Table (Chapter 5, Table 5.11)
# ==============================================================================
class ModelVersion(Base):
    __tablename__ = "model_versions"

    id = Column(String(36), primary_key=True, default=new_uuid)
    version = Column(String(80), unique=True, nullable=False)
    source = Column(String(16), nullable=False)  # 'shipped' or 'trained'
    backbone = Column(String(120), nullable=True)
    macro_f1 = Column(Float, nullable=True)
    balanced_accuracy = Column(Float, nullable=True)
    mcc = Column(Float, nullable=True)
    per_class_recall = Column(JSON, nullable=True)
    confusion_matrix = Column(JSON, nullable=True)
    temperature = Column(Float, nullable=True)
    abstain_threshold = Column(Float, nullable=True)
    is_active = Column(Boolean, nullable=False, default=False)
    activated_at = Column(DateTime(timezone=True), nullable=True)
    created_at = Column(DateTime(timezone=True), nullable=False, default=utcnow)

    # Relationships
    predictions = relationship("Prediction", back_populates="model_version")


# ==============================================================================
# 7. Scans Table (Chapter 5, Table 5.12)
# ==============================================================================
class Scan(Base):
    __tablename__ = "scans"

    id = Column(String(36), primary_key=True, default=new_uuid)
    user_id = Column(
        String(36),
        ForeignKey("users.id", ondelete="SET NULL"),
        nullable=True,
    )
    device_id = Column(String(64), nullable=True)
    flock_id = Column(
        String(36),
        ForeignKey("flocks.id", ondelete="SET NULL"),
        nullable=True,
    )
    idempotency_key = Column(String(64), unique=True, nullable=True)
    image_count = Column(SmallInteger, nullable=False, default=1)
    perceptual_hashes = Column(JSON, nullable=False, default=list)
    image_width = Column(Integer, nullable=True)
    image_height = Column(Integer, nullable=True)
    locale = Column(
        Enum(*LOCALES, name="locale", native_enum=False),
        nullable=False,
        default="en",
    )
    created_at = Column(DateTime(timezone=True), nullable=False, default=utcnow)

    # Relationships
    user = relationship("User", back_populates="scans")
    flock = relationship("Flock", back_populates="scans")
    prediction = relationship("Prediction", back_populates="scan", uselist=False, cascade="all, delete-orphan")
    feedback = relationship("Feedback", back_populates="scan", uselist=False, cascade="all, delete-orphan")

    __table_args__ = (
        Index("scans_user_created_idx", "user_id", "created_at"),
        Index("scans_device_created_idx", "device_id", "created_at"),
    )


# ==============================================================================
# 8. Predictions Table (Chapter 5, Table 5.13)
# ==============================================================================
class Prediction(Base):
    __tablename__ = "predictions"

    id = Column(String(36), primary_key=True, default=new_uuid)
    scan_id = Column(
        String(36),
        ForeignKey("scans.id", ondelete="CASCADE"),
        nullable=False,
    )
    model_version_id = Column(
        String(36),
        ForeignKey("model_versions.id", ondelete="SET NULL"),
        nullable=True,
    )
    predicted_class = Column(
        Enum(*DISEASE_CLASSES, name="disease_class", native_enum=False),
        nullable=True,
    )
    probabilities = Column(JSON, nullable=True)
    calibrated_confidence = Column(Float, nullable=True)
    certainty = Column(
        Enum(*CERTAINTY_LEVELS, name="certainty", native_enum=False),
        nullable=False,
    )
    conformal_set = Column(JSON, nullable=False, default=list)
    abstained = Column(Boolean, nullable=False, default=False)
    abstain_reason = Column(
        Enum(*ABSTAIN_REASONS, name="abstain_reason", native_enum=False),
        nullable=True,
    )
    energy_score = Column(Float, nullable=True)
    severity = Column(
        Enum(*SEVERITY_LEVELS, name="severity", native_enum=False),
        nullable=True,
    )
    urgency = Column(
        Enum(*URGENCY_LEVELS, name="urgency", native_enum=False),
        nullable=True,
    )
    triage_rules = Column(JSON, nullable=False, default=list)
    flock_signals = Column(JSON, nullable=True)
    decode_ms = Column(Float, nullable=True)
    preprocess_ms = Column(Float, nullable=True)
    inference_ms = Column(Float, nullable=True)
    total_ms = Column(Float, nullable=True)
    created_at = Column(DateTime(timezone=True), nullable=False, default=utcnow)

    # Relationships
    scan = relationship("Scan", back_populates="prediction")
    model_version = relationship("ModelVersion", back_populates="predictions")

    __table_args__ = (
        Index("predictions_scan_idx", "scan_id"),
        Index("predictions_class_created_idx", "predicted_class", "created_at"),
    )


# ==============================================================================
# 9. Feedback Table (Chapter 5, Table 5.14)
# ==============================================================================
class Feedback(Base):
    __tablename__ = "feedback"

    id = Column(String(36), primary_key=True, default=new_uuid)
    scan_id = Column(
        String(36),
        ForeignKey("scans.id", ondelete="CASCADE"),
        unique=True,
        nullable=False,
    )
    user_id = Column(
        String(36),
        ForeignKey("users.id", ondelete="SET NULL"),
        nullable=True,
    )
    was_helpful = Column(Boolean, nullable=True)
    actual_class = Column(
        Enum(*DISEASE_CLASSES, name="disease_class", native_enum=False),
        nullable=True,
    )
    confirmed_by_vet = Column(Boolean, nullable=False, default=False)
    comment = Column(Text, nullable=True)
    created_at = Column(DateTime(timezone=True), nullable=False, default=utcnow)

    # Relationships
    scan = relationship("Scan", back_populates="feedback")

    __table_args__ = (
        Index("feedback_actual_class_idx", "actual_class"),
    )


# ==============================================================================
# 10. Audit Logs Table (Chapter 5, Table 5.15)
# ==============================================================================
class AuditLog(Base):
    __tablename__ = "audit_logs"

    id = Column(String(36), primary_key=True, default=new_uuid)
    actor_id = Column(
        String(36),
        ForeignKey("users.id", ondelete="SET NULL"),
        nullable=True,
    )
    action = Column(String(80), nullable=False)
    entity_type = Column(String(40), nullable=False)
    entity_id = Column(String(80), nullable=False)
    old_values = Column(JSON, nullable=True)
    new_values = Column(JSON, nullable=True)
    created_at = Column(DateTime(timezone=True), nullable=False, default=utcnow)

