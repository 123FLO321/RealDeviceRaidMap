from pathlib import Path
import os
import time
import math
import datetime
import time
from sqlalchemy import create_engine, Column, Boolean, Integer, String, Float, SmallInteger, \
        BigInteger, ForeignKey, Index, UniqueConstraint, \
        create_engine, cast, func, desc, asc, desc, and_, exists
from sqlalchemy.orm import sessionmaker, relationship, eagerload, foreign, remote
from sqlalchemy.types import TypeDecorator, Numeric, Text, TIMESTAMP
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm.exc import NoResultFound
from config import DB_ENGINE
from logging import basicConfig, getLogger, FileHandler, StreamHandler, DEBUG, INFO, ERROR, Formatter

LOG = getLogger('')

if DB_ENGINE.startswith('mysql'):
    from sqlalchemy.dialects.mysql import TINYINT, MEDIUMINT, BIGINT, DOUBLE, LONGTEXT

    TINY_TYPE = TINYINT(unsigned=True)          # 0 to 255
    MEDIUM_TYPE = MEDIUMINT(unsigned=True)      # 0 to 4294967295
    UNSIGNED_HUGE_TYPE = BIGINT(unsigned=True)  # 0 to 18446744073709551615
    HUGE_TYPE = BigInteger
    PRIMARY_HUGE_TYPE = HUGE_TYPE 
    FLOAT_TYPE = DOUBLE(precision=18, scale=14, asdecimal=False)
    LONG_TEXT = LONGTEXT
elif DB_ENGINE.startswith('postgres'):
    from sqlalchemy.dialects.postgresql import DOUBLE_PRECISION, TEXT

    class NumInt(TypeDecorator):
        '''Modify Numeric type for integers'''
        impl = Numeric

        def process_bind_param(self, value, dialect):
            if value is None:
                return None
            return int(value)

        def process_result_value(self, value, dialect):
            if value is None:
                return None
            return int(value)

        @property
        def python_type(self):
            return int

    TINY_TYPE = SmallInteger                    # -32768 to 32767
    MEDIUM_TYPE = Integer                       # -2147483648 to 2147483647
    UNSIGNED_HUGE_TYPE = NumInt(precision=20, scale=0)   # up to 20 digits
    HUGE_TYPE = BigInteger
    PRIMARY_HUGE_TYPE = HUGE_TYPE 
    FLOAT_TYPE = DOUBLE_PRECISION(asdecimal=False)
    LONG_TEXT = TEXT
else:
    class TextInt(TypeDecorator):
        '''Modify Text type for integers'''
        impl = Text

        def process_bind_param(self, value, dialect):
            return str(value)

        def process_result_value(self, value, dialect):
            return int(value)

    TINY_TYPE = SmallInteger
    MEDIUM_TYPE = Integer
    UNSIGNED_HUGE_TYPE = TextInt
    HUGE_TYPE = Integer
    PRIMARY_HUGE_TYPE = HUGE_TYPE 
    FLOAT_TYPE = Float(asdecimal=False)

Base = declarative_base()
engine = create_engine(DB_ENGINE)

class Fort(Base):
    __tablename__ = 'forts'

    id = Column(Integer, primary_key=True)
    external_id = Column(String(35), unique=True)
    lat = Column(FLOAT_TYPE)
    lon = Column(FLOAT_TYPE)
    name = Column(String(128))
    url = Column(String(200))
    sponsor = Column(SmallInteger)
    weather_cell_id = Column(UNSIGNED_HUGE_TYPE)
    park = Column(String(128))
    parkid = Column(HUGE_TYPE)

    sightings = relationship(
        'FortSighting',
        backref='fort',
        order_by='FortSighting.last_modified'
    )

    raids = relationship(
        'Raid',
        backref='fort',
        order_by='Raid.time_end'
    )

class FortSighting(Base):
    __tablename__ = 'fort_sightings'

    id = Column(PRIMARY_HUGE_TYPE, primary_key=True)
    fort_id = Column(Integer, ForeignKey('forts.id'))
    last_modified = Column(Integer, index=True)
    team = Column(TINY_TYPE)
    guard_pokemon_id = Column(SmallInteger)
    slots_available = Column(SmallInteger)
    is_in_battle = Column(Boolean, default=False)
    updated = Column(Integer,default=time,onupdate=time)
    total_cp = Column(SmallInteger)

    __table_args__ = (
        UniqueConstraint(
            'fort_id',
            'last_modified',
            name='fort_id_last_modified_unique'
        ),
    )

class Raid(Base):
    __tablename__ = 'raids'

    id = Column(Integer, primary_key=True)
    external_id = Column(BigInteger, unique=True)
    fort_id = Column(Integer, ForeignKey('forts.id'))
    level = Column(TINY_TYPE)
    pokemon_id = Column(SmallInteger)
    move_1 = Column(SmallInteger)
    move_2 = Column(SmallInteger)
    time_spawn = Column(Integer, index=True)
    time_battle = Column(Integer)
    time_end = Column(Integer)
    cp = Column(Integer)

class GymImage(Base):
    __tablename__ = 'gym_images'
    
    id = Column(Integer, primary_key=True)
    fort_id = Column(Integer)
    param_1 = Column(Integer)
    param_2 = Column(Integer)
    param_3 = Column(Integer)
    param_4 = Column(Integer)
    param_5 = Column(Integer)
    param_6 = Column(Integer)
    created = Column(Integer,default=time)

class PokemonImage(Base):
    __tablename__ = 'pokemon_images'
    
    id = Column(Integer, primary_key=True)
    pokemon_id = Column(Integer)
    param_1 = Column(Integer)
    param_2 = Column(Integer)
    param_3 = Column(Integer)
    param_4 = Column(Integer)
    param_5 = Column(Integer)
    param_6 = Column(Integer)
    param_7 = Column(Integer)
    created = Column(Integer,default=time)

# create gym_images and pokemon_images table if non
Base.metadata.create_all(bind=engine)
Session = sessionmaker(bind=engine)

def get_gym_images(session):
    return session.query(GymImage)

def get_pokemon_images(session):
    return session.query(PokemonImage)

unknown_fort_name = 'UNKNOWN FORT'
def get_unknown_fort_id(session):
    unknown_fort = session.query(Fort).filter_by(name=unknown_fort_name).first()
    # Check UNKNOWN FORT existance if not, add
    if unknown_fort is None:
        session.add(Fort(name=unknown_fort_name))
        session.commit()
        unknown_fort = session.query(Fort).filter_by(name=unknown_fort_name).first()
    return unknown_fort.id

not_a_fort_name = 'NOT A FORT'
def get_not_a_fort_id(session):
    not_a_fort = session.query(Fort).filter_by(name=not_a_fort_name).first()
    # Check NOT A FORT existance if not, add
    if not_a_fort is None:
        session.add(Fort(name=not_a_fort_name))
        session.commit()
        not_a_fort = session.query(Fort).filter_by(name=not_a_fort_name).first()
    return not_a_fort.id

def get_raid_battle_time(session, fort_id):
    raid = session.query(Raid).filter(Raid.fort_id == str(fort_id)).first()
    if raid is None:
        session.add(Raid(fort_id = str(fort_id)))
        session.commit()
        raid = session.query(Raid).filter(Raid.fort_id == str(fort_id)).first()
        raid.time_battle = 0
    if raid.time_battle is None:
        raid.time_battle = 0
    return raid.time_battle

def get_raid_pokemon_id(session, fort_id):
    raid = session.query(Raid).filter(Raid.fort_id == str(fort_id)).first()
    if raid is None:
        session.add(Raid(fort_id = str(fort_id)))
        session.commit()
        raid = session.query(Raid).filter(Raid.fort_id == str(fort_id)).first()
        raid.pokemon_id = -1
    if raid.pokemon_id is None:
        raid.pokemon_id = -1
    return raid.pokemon_id
    
def update_raid_egg(session, fort_id, level, time_battle):
    raid = session.query(Raid).filter_by(fort_id=str(fort_id)).first()
    if raid is None:
        session.add(Raid(fort_id = str(fort_id)))
        session.commit()
        raid = session.query(Raid).filter_by(fort_id=str(fort_id)).first()        
    raid.level = int(level)
    raid.pokemon_id = 0
    raid.time_spawn = time_battle - 3600
    raid.time_battle = time_battle
    raid.time_end = time_battle + 2700
    session.commit()

def update_raid_mon(session, fort_id, pokemon_id):
    raid = session.query(Raid).filter_by(fort_id=str(fort_id)).first()
    if raid is None:
        session.add(Raid(fort_id = str(fort_id)))
        session.commit()
        raid = session.query(Raid).filter_by(fort_id=str(fort_id)).first()        
    raid.pokemon_id = int(pokemon_id)
    session.commit()
    
def updata_fort_sighting(session, fort_id, unix_time):
    fort_sighting = session.query(FortSighting).filter_by(fort_id=str(fort_id)).first()
    if fort_sighting is None:
        session.add(FortSighting(fort_id = str(fort_id), last_modified = int(unix_time), updated = int(unix_time)))
        session.commit()
        fort_sighting = session.query(FortSighting).filter_by(fort_id=str(fort_id)).first()            
    fort_sighting.updated = int(unix_time)
    fort_sighting.last_modified = int(unix_time)
    session.commit()

def add_gym_image(session,fort_id,top_mean0,top_mean1,top_mean2,left_mean0,left_mean1,left_mean2):
    session.add(GymImage(fort_id=fort_id,param_1=top_mean0,param_2=top_mean1,param_3=top_mean2,param_4=left_mean0,param_5=left_mean1,param_6=left_mean2,created=int(datetime.datetime.now().timestamp())))
    session.commit()

def update_gym_image(session,gym_image_id,gym_image_fort_id):
    gym_image = session.query(GymImage).filter_by(id=gym_image_id).first()
    if gym_image is None:
        LOG.info('No gym image found with id:{}'.format(gym_image_fort_id))
        return False
    else:
        gym_image.fort_id = gym_image_fort_id
        session.commit()
        LOG.info('gym image {} is set to fort_id {}'.format(gym_image_id,gym_image_fort_id))
        return True

def add_pokemon_image(session,mon_id,mean1,mean2,mean3,mean4,mean5,mean6,mean7):
    session.add(PokemonImage(pokemon_id=mon_id,param_1=mean1,param_2=mean2,param_3=mean3,param_4=mean4,param_5=mean5,param_6=mean6,param_7=mean7,created=int(datetime.datetime.now().timestamp())))
    session.commit()

def update_pokemon_image(session,pokemon_image_id, pokemon_id):
    pokemon_image = session.query(PokemonImage).filter_by(id=pokemon_image_id).first()
    if pokemon_image is None:
        LOG.info('No pokemon image found with id: {}'.format(pokemon_image_id))
        return False
    else:
        pokemon_image.pokemon_id = pokemon_id
        session.commit()
        LOG.info('pokemon image {} is set to pokemon_id {}'.format(pokemon_image_id,pokemon_id))
        return True        

def get_gym_image_id(session,top_mean0,top_mean1,top_mean2,left_mean0,left_mean1,left_mean2):
    gym_image = session.query(GymImage).filter_by(param_1=top_mean0,param_2=top_mean1,param_3=top_mean2,param_4=left_mean0,param_5=left_mean1,param_6=left_mean2).first()
    if gym_image is None:
        unknown_fort_id = get_unknown_fort_id(session)
        add_gym_image(session,unknown_fort_id,top_mean0,top_mean1,top_mean2,left_mean0,left_mean1,left_mean2)
        gym_image = session.query(GymImage).filter_by(param_1=top_mean0,param_2=top_mean1,param_3=top_mean2,param_4=left_mean0,param_5=left_mean1,param_6=left_mean2).first()
    return gym_image.id

def get_gym_image_fort_id(session, gym_image_id):
    gym_image = session.query(GymImage).filter_by(id=gym_image_id).first()
    if gym_image is None:
        return None
    else:
        return gym_image.fort_id

def get_pokemon_image_id(session,mean1_in,mean2_in,mean3_in,mean4_in,mean5_in,mean6_in,mean7_in):
    pokemon_image = session.query(PokemonImage).filter_by(param_1=mean1_in,param_2=mean2_in,param_3=mean3_in,param_4=mean4_in,param_5=mean5_in,param_6=mean6_in,param_7=mean7_in).first()
    if pokemon_image is None:
        add_pokemon_image(session,0,mean1_in,mean2_in,mean3_in,mean4_in,mean5_in,mean6_in,mean7_in)
        pokemon_image = session.query(PokemonImage).filter_by(param_1=mean1_in,param_2=mean2_in,param_3=mean3_in,param_4=mean4_in,param_5=mean5_in,param_6=mean6_in,param_7=mean7_in).first()
    return pokemon_image.id

def get_pokemon_image_pokemon_id(session, pokemon_image_id):
    pokemon_image = session.query(PokemonImage).filter_by(id=pokemon_image_id).first()
    if pokemon_image is None:
        return None
    else:
        return pokemon_image.pokemon_id

def get_forts(session):
    return session.query(Fort).all()

