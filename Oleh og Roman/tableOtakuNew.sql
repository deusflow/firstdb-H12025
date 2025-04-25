CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    username VARCHAR(50) UNIQUE,
    email VARCHAR(255) UNIQUE,
    password_hash TEXT,
    join_date DATE DEFAULT CURRENT_DATE,
    balance INTEGER DEFAULT 500 CHECK(balance >= 0), -- защита от ухода в минус
    role VARCHAR (15) DEFAULT 'user' CHECK (role in ('user', 'admin')) -- на будущее, можно будет пользователя
    -- наделять правами админа
);

CREATE TABLE items (
    item_id SERIAL PRIMARY KEY,
    item_name VARCHAR(100) UNIQUE,
    item_type VARCHAR(10) CHECK (item_type IN ('Avatar', 'Weapon')),
    rarity VARCHAR(20) CHECK (rarity IN ('common', 'rare', 'epic', 'legendary')),
    damage_min INTEGER CHECK (damage_min IS NULL OR damage_min >= 0),
    damage_max INTEGER CHECK (damage_max IS NULL OR damage_max >= damage_min),
    image_url TEXT,
    description TEXT
);

CREATE TABLE inventory (
    inventory_id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
    item_id INTEGER REFERENCES items(item_id),
    quantity INTEGER DEFAULT 1 CHECK (quantity >= 0),
    UNIQUE(user_id, item_id)
);

CREATE TABLE shop (
    shop_item_id SERIAL PRIMARY KEY,
    item_id INTEGER REFERENCES items(item_id),
    price INTEGER CHECK(price >= 0),
    quantity INTEGER DEFAULT 1 CHECK(quantity >= 0),
    available BOOLEAN DEFAULT TRUE
);

CREATE TABLE trades (
    trade_id SERIAL PRIMARY KEY,
    seller_id INTEGER REFERENCES users(id) ON DELETE SET NULL,
    buyer_id INTEGER REFERENCES users(id) ON DELETE SET NULL,
    item_id INTEGER REFERENCES items(item_id),
    price INTEGER CHECK(price >= 0),
    trade_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- All user items
SELECT items.item_name, items.item_type, inventory.quantity
FROM inventory
JOIN items ON inventory.item_id = items.item_id --JOIN between inventory and items tables to get details about each item.
WHERE inventory.user_id = 1;

-- all items in the shop
SELECT items.item_name, shop.price, shop.quantity
FROM shop
JOIN items ON shop.item_id = items.item_id; --JOIN between shop and items tables to get product names and quantities in the store.

--All items of the type "weapon"
SELECT *
FROM items
WHERE item_type = 'Weapon';

SELECT * FROM inventory WHERE user_id = 1;

---All avatars that the user does not have
SELECT *
FROM items
WHERE item_type = 'Avatar'
  AND item_id NOT IN (
    SELECT item_id FROM inventory WHERE user_id = 1
);--The nested query checks what items are in this user's inventory.

--How many items of each type does the user have?
SELECT items.item_type, COUNT(*) AS total
FROM inventory
    JOIN items ON inventory.item_id = items.item_id
GROUP BY items.item_type; --Groups the results by the item_type field to display the quantity of each type.

--How much money did the user spend on transactions in total?
SELECT SUM(price) AS total_spent
FROM trades
WHERE buyer_id = 1;

--Last 10 transactions with information about the product and seller
SELECT trades.trade_date, items.item_name, trades.price, users.username AS seller_name
FROM trades
    JOIN items ON trades.item_id = items.item_id
    LEFT JOIN users ON trades.seller_id = users.id
ORDER BY trades.trade_date DESC
LIMIT 10;



--DROP TABLE IF EXISTS inventory;
--DROP TABLE IF EXISTS weapons;
--DROP TABLE IF EXISTS avatars;
--DROP TABLE IF EXISTS users;


