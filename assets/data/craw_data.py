import os
from bs4 import BeautifulSoup
import pandas as pd
import requests

# URL của trang web cần crawl
url = 'https://phuclong.com.vn/category/thuc-uong'

# Gửi yêu cầu HTTP GET để lấy nội dung trang web
response = requests.get(url)
response.raise_for_status()  # Kiểm tra nếu yêu cầu thất bại

# Phân tích cú pháp nội dung HTML
soup = BeautifulSoup(response.content, 'html.parser')

# Tạo danh sách để chứa dữ liệu
items = []
# Tìm tất cả các mục sản phẩm
for product in soup.find_all('div', class_='product-item'):
    # Lấy tên sản phẩm
    name = product.find('div', class_='item-name').get_text(strip=True)
    
    # Lấy giá sản phẩm
    price_tag = product.find('p', class_='item-price')
    price = price_tag.get_text(strip=True) if price_tag else 'Không có giá'

    description_tag = product.find('div', class_='item-desc')
    description = description_tag.get_text(strip=True) if description_tag else 'Không có mô tả'
    
    # Lấy URL hình ảnh sản phẩm
    img_tag = product.find('img', class_='item-img img-responsive center-block lazy')
    img_url = img_tag['data-original'] if img_tag else 'Không có ảnh'
    
    # Thêm vào danh sách items
    items.append({
        'name': name,
        'price': price,
        'img_url': img_url,
        'desc': description
    })

# In ra kết quả
for item in items:
    print(f"Item name: {item['name']}")
    print(f"Price: {item['price']}")
    print(f"Image URL: {item['img_url']}")
    print('-' * 40)

# Chuyển đổi danh sách items thành DataFrame
df = pd.DataFrame(items)

# Lưu DataFrame vào file CSV
df.to_csv('products.csv', index=False, encoding='utf-8')

print("Data has been written to products.csv")

# Lấy đường dẫn thư mục của script
script_dir = os.path.dirname(os.path.abspath(__file__))

# Tạo thư mục để lưu trữ hình ảnh nếu chưa tồn tại
images_dir = os.path.join(script_dir, 'images')
os.makedirs(images_dir, exist_ok=True)

# Tải tất cả hình ảnh từ img_url về thư mục
for item in items:
    img_url = item['img_url']
    if img_url != 'Không có ảnh':
        img_data = requests.get(img_url).content
        img_name = os.path.join(images_dir, f"{item['name']}.png")
        with open(img_name, 'wb') as img_file:
            img_file.write(img_data)
        print(f"Downloaded {img_name}")

print("All images have been downloaded.")