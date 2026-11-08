"""
Simulación aproximada del ritmo de progresión (semana 24). Uso: python3 tools/balance_sim.py
Cambia los valores de enemies, OVERHEAD o la XP del jefe para ver cómo afectan. Es una ESTIMACIÓN:
la prueba pública manda.
"""
import math
def xp_to_next(l): return math.floor(100*l**1.5/10+0.5)*10
cum=[0]
for l in range(1,20): cum.append(cum[-1]+xp_to_next(l))
def level_for(xp):
    l=1
    while l<20 and xp>=cum[l]: l+=1
    return l
enemies={'Thornling':(60,15,10),'Spitter':(45,12,12),'Sentry':(220,40,30)}
# zonas: (nombre, [(enemy, level)], fragments, quests xp list)
zones=[
 ('Linde',[('Thornling',1),('Thornling',2),('Thornling',3),('Spitter',3)],3,[60,120,150,200]),
 ('Ruinas',[('Thornling',6),('Sentry',7),('Sentry',9),('Spitter',8)],3,[250,500]),
 ('Hondonada',[('Thornling',12),('Spitter',13),('Sentry',14),('Thornling',15),('Spitter',16)],3,[900]),
]
OVERHEAD=5.0  # factor: buscar, esquivar, moverse, recibir daño (tiempo total / tiempo pegando)
def dps(level, rarity=1.0):
    base=10*rarity*(1+0.04*(level-1))/0.35
    return base*1.05
xp=0; t=0
targets={5:35,10:90,15:150,20:270}
print("Supuesto: TTK real = vida/DPS × %.1f (búsqueda, esquivas, viaje)"%OVERHEAD)
for name,mobs,frags,quests in zones:
    xp+=sum(quests)+frags*100
    # farm until next zone threshold
    goal={'Linde':cum[5-1]+1, 'Ruinas':cum[12-1], 'Hondonada':cum[15-1]}[name]
    i=0
    while xp<goal:
        e,l=mobs[i%len(mobs)]; i+=1
        hp,hpl,xpl=enemies[e]; H=hp+hpl*(l-1)
        lvl=level_for(xp)
        rar=1.25 if name!='Linde' else 1.0
        ttk=H/dps(lvl,rar)*OVERHEAD
        t+=ttk; xp+=xpl*l
    print(f"{name}: sale a nivel {level_for(xp)} con {xp} XP, minuto {t/60:.0f}, kills {i}")
xp+=3000+4000
print("Tras jefe + Q08:",level_for(xp), xp)
# repetir jefe hasta 20
boss=0
while level_for(xp)<20:
    xp+=4000; boss+=1; t+=6*60
print(f"Nivel 20 tras {boss} jefes más; minuto total aprox {t/60:.0f}")
