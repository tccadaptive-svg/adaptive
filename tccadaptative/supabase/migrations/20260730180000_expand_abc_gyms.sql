/*
  # AdaptiveMove - Expand ABC Region Gym Coverage

  Adds more gyms across the ABC Paulista region (Santo André, São Bernardo
  do Campo, São Caetano do Sul, Diadema, Mauá, Ribeirão Pires and Rio Grande
  da Serra) so the map view has richer, more evenly distributed coverage
  instead of being concentrated mostly in central São Paulo.

  Idempotent: each row is only inserted if a gym with the same name doesn't
  already exist, so re-running this migration is safe.
*/

INSERT INTO gyms (name, address, latitude, longitude, phone, website, rating, amenities, photos, verified)
SELECT * FROM (VALUES
  (
    'SmartFit - São Bernardo Centro',
    'R. Marechal Deodoro, 500 - Centro, São Bernardo do Campo - SP',
    -23.6939,
    -46.5650,
    '(11) 4330-1200',
    'https://www.smartfit.com.br',
    4.4,
    '["Musculação", "Cardio", "Aulas coletivas", "Vestiários", "Acessível para cadeirantes", "24h"]'::jsonb,
    '["https://images.pexels.com/photos/1552242/pexels-photo-1552242.jpeg"]'::jsonb,
    true
  ),
  (
    'Bio Ritmo - São Caetano',
    'Av. Goiás, 1200 - Centro, São Caetano do Sul - SP',
    -23.6229,
    -46.5546,
    '(11) 4229-8800',
    'https://www.bioritmoacademia.com.br',
    4.5,
    '["Musculação", "Cardio", "Piscina", "Spinning", "Personal Trainer", "Acessível para cadeirantes"]'::jsonb,
    '["https://images.pexels.com/photos/1153369/pexels-photo-1153369.jpeg"]'::jsonb,
    true
  ),
  (
    'Academia Vida Ativa - Diadema',
    'Av. Piraporinha, 780 - Centro, Diadema - SP',
    -23.6858,
    -46.6216,
    '(11) 4053-6611',
    null,
    4.2,
    '["Musculação", "Cardio", "Funcional", "Vestiários", "Estacionamento"]'::jsonb,
    '["https://images.pexels.com/photos/3076509/pexels-photo-3076509.jpeg"]'::jsonb,
    true
  ),
  (
    'Fórmula Fitness - Mauá',
    'Av. Barão de Mauá, 900 - Centro, Mauá - SP',
    -23.6678,
    -46.4614,
    '(11) 4512-9090',
    null,
    4.0,
    '["Musculação", "Cardio", "Aulas coletivas", "Personal Trainer"]'::jsonb,
    '["https://images.pexels.com/photos/2261477/pexels-photo-2261477.jpeg"]'::jsonb,
    false
  ),
  (
    'SmartFit - Rudge Ramos (SBC)',
    'Av. Rudge Ramos, 350 - Rudge Ramos, São Bernardo do Campo - SP',
    -23.6553,
    -46.5765,
    '(11) 4128-4500',
    'https://www.smartfit.com.br',
    4.3,
    '["Musculação", "Cardio", "Aulas coletivas", "Acessível para cadeirantes", "24h"]'::jsonb,
    '["https://images.pexels.com/photos/2261481/pexels-photo-2261481.jpeg"]'::jsonb,
    true
  ),
  (
    'Espaço Inclusão Fitness - Ribeirão Pires',
    'R. Rio Grande do Sul, 210 - Centro, Ribeirão Pires - SP',
    -23.7136,
    -46.4104,
    '(11) 4825-1177',
    null,
    4.7,
    '["Musculação", "Cardio", "Yoga", "Pilates", "Acessível para cadeirantes", "Rampa de acesso", "Banheiro adaptado", "Equipamentos adaptados", "Libras disponível"]'::jsonb,
    '["https://images.pexels.com/photos/4162449/pexels-photo-4162449.jpeg"]'::jsonb,
    true
  ),
  (
    'Academia Bem Estar - Santo André Centro',
    'R. Coronel Trevisan, 300 - Centro, Santo André - SP',
    -23.6528,
    -46.5384,
    '(11) 4990-2233',
    null,
    4.1,
    '["Musculação", "Cardio", "Hidroginástica", "Fisioterapia", "Acessível para cadeirantes"]'::jsonb,
    '["https://images.pexels.com/photos/3253501/pexels-photo-3253501.jpeg"]'::jsonb,
    true
  ),
  (
    'Bodytech - São Bernardo do Campo',
    'Al. Terracota, 545 - Bairro Assunção, São Bernardo do Campo - SP',
    -23.6789,
    -46.5566,
    '(11) 4127-7700',
    'https://www.bodytech.com.br',
    4.6,
    '["Musculação", "Cardio", "Piscina", "Sauna", "Personal Trainer", "Pilates", "Acessível para cadeirantes"]'::jsonb,
    '["https://images.pexels.com/photos/1552249/pexels-photo-1552249.jpeg"]'::jsonb,
    true
  ),
  (
    'Fit Point - Rio Grande da Serra',
    'Av. Portugal, 150 - Centro, Rio Grande da Serra - SP',
    -23.7397,
    -46.4083,
    '(11) 4825-4400',
    null,
    3.9,
    '["Musculação", "Cardio", "Funcional", "Vestiários"]'::jsonb,
    '["https://images.pexels.com/photos/3076509/pexels-photo-3076509.jpeg"]'::jsonb,
    false
  ),
  (
    'Academia Adaptada Movimento Livre - Mauá',
    'R. Governador Pedro de Toledo, 480 - Vila Noêmia, Mauá - SP',
    -23.6612,
    -46.4732,
    '(11) 4512-8822',
    null,
    4.8,
    '["Musculação", "Cardio", "Acessível para cadeirantes", "Rampa de acesso", "Banheiro adaptado", "Personal Trainer inclusivo", "Equipamentos adaptados", "Libras disponível"]'::jsonb,
    '["https://images.pexels.com/photos/4162449/pexels-photo-4162449.jpeg", "https://images.pexels.com/photos/3253501/pexels-photo-3253501.jpeg"]'::jsonb,
    true
  )
) AS v(name, address, latitude, longitude, phone, website, rating, amenities, photos, verified)
WHERE NOT EXISTS (
  SELECT 1 FROM gyms g WHERE g.name = v.name
);
