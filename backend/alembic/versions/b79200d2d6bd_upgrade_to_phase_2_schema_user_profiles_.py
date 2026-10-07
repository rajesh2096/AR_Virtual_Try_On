"""Upgrade to Phase 2 schema: user profiles, person profiles, taxonomy, favorites, outfits, and tryon

Revision ID: b79200d2d6bd
Revises: 
Create Date: 2026-10-07 16:53:50.636134

"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa
from sqlalchemy.dialects import mysql

# revision identifiers, used by Alembic.
revision: str = 'b79200d2d6bd'
down_revision: Union[str, Sequence[str], None] = None
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    # 1. Update garments columns
    op.add_column('garments', sa.Column('subcategory_id', sa.Integer(), nullable=True))
    op.add_column('garments', sa.Column('brand', sa.String(length=100), nullable=True))
    op.add_column('garments', sa.Column('primary_color', sa.String(length=50), nullable=True))
    op.add_column('garments', sa.Column('size', sa.String(length=20), nullable=True))
    op.add_column('garments', sa.Column('style', sa.String(length=50), nullable=True))
    op.add_column('garments', sa.Column('description', sa.Text(), nullable=True))
    op.add_column('garments', sa.Column('is_archived', sa.Boolean(), server_default='0', nullable=False))
    
    op.create_index('idx_user_archived_created', 'garments', ['user_id', 'is_archived', 'created_at'], unique=False)
    op.create_index(op.f('ix_garments_is_archived'), 'garments', ['is_archived'], unique=False)
    op.create_index(op.f('ix_garments_subcategory_id'), 'garments', ['subcategory_id'], unique=False)
    op.create_foreign_key('fk_garments_subcategory', 'garments', 'subcategories', ['subcategory_id'], ['id'], ondelete='SET NULL')

    # 2. Update tryon_sessions columns
    op.add_column('tryon_sessions', sa.Column('person_profile_id', sa.Integer(), nullable=True))
    op.add_column('tryon_sessions', sa.Column('outfit_id', sa.Integer(), nullable=True))
    op.add_column('tryon_sessions', sa.Column('session_type', sa.String(length=50), server_default='single', nullable=False))
    op.add_column('tryon_sessions', sa.Column('error_message', sa.Text(), nullable=True))
    
    op.alter_column('tryon_sessions', 'garment_id',
               existing_type=mysql.INTEGER(),
               nullable=True)
    op.alter_column('tryon_sessions', 'person_image_path',
               existing_type=mysql.VARCHAR(length=500),
               nullable=True)
               
    op.create_index(op.f('ix_tryon_sessions_outfit_id'), 'tryon_sessions', ['outfit_id'], unique=False)
    op.create_index(op.f('ix_tryon_sessions_person_profile_id'), 'tryon_sessions', ['person_profile_id'], unique=False)
    
    # Safe FK replacement
    op.drop_constraint('tryon_sessions_ibfk_2', 'tryon_sessions', type_='foreignkey')
    op.create_foreign_key('fk_tryon_sessions_garment', 'tryon_sessions', 'garments', ['garment_id'], ['id'], ondelete='SET NULL')
    op.create_foreign_key('fk_tryon_sessions_person_profile', 'tryon_sessions', 'person_profiles', ['person_profile_id'], ['id'], ondelete='SET NULL')
    op.create_foreign_key('fk_tryon_sessions_outfit', 'tryon_sessions', 'outfits', ['outfit_id'], ['id'], ondelete='SET NULL')


def downgrade() -> None:
    op.drop_constraint('fk_tryon_sessions_outfit', 'tryon_sessions', type_='foreignkey')
    op.drop_constraint('fk_tryon_sessions_person_profile', 'tryon_sessions', type_='foreignkey')
    op.drop_constraint('fk_tryon_sessions_garment', 'tryon_sessions', type_='foreignkey')
    op.create_foreign_key('tryon_sessions_ibfk_2', 'tryon_sessions', 'garments', ['garment_id'], ['id'], ondelete='CASCADE')
    
    op.drop_index(op.f('ix_tryon_sessions_person_profile_id'), table_name='tryon_sessions')
    op.drop_index(op.f('ix_tryon_sessions_outfit_id'), table_name='tryon_sessions')
    op.alter_column('tryon_sessions', 'person_image_path',
               existing_type=mysql.VARCHAR(length=500),
               nullable=False)
    op.alter_column('tryon_sessions', 'garment_id',
               existing_type=mysql.INTEGER(),
               nullable=False)
    op.drop_column('tryon_sessions', 'error_message')
    op.drop_column('tryon_sessions', 'session_type')
    op.drop_column('tryon_sessions', 'outfit_id')
    op.drop_column('tryon_sessions', 'person_profile_id')
    
    op.drop_constraint('fk_garments_subcategory', 'garments', type_='foreignkey')
    op.drop_index(op.f('ix_garments_subcategory_id'), table_name='garments')
    op.drop_index(op.f('ix_garments_is_archived'), table_name='garments')
    op.drop_index('idx_user_archived_created', table_name='garments')
    op.drop_column('garments', 'is_archived')
    op.drop_column('garments', 'description')
    op.drop_column('garments', 'style')
    op.drop_column('garments', 'size')
    op.drop_column('garments', 'primary_color')
    op.drop_column('garments', 'brand')
    op.drop_column('garments', 'subcategory_id')
