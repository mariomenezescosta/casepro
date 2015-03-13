config = dict(    
    port='8030',
    app_dir='upartners',
    friendly_name='U-Report Partners',
    repository='ssh://git@github.com/rapidpro/ureport-partners.git',
    domain='ureport-partners.io',
    name='upartners',
    repo='ureport-partners',
    user='upartners',
    env='env',
    settings='settings.py.dev',
    dbms='psql',
    db='upartners',
    custom_domains='*.ureport-partners.io ureport-partners.io upartners.staging.nyaruka.com *.upartners.staging.nyaruka.com',
    prod_host='upartners1',
    sqldump=False,
    celery=True,
    processes=('celery',),
    compress=True,
)
