--Kiểm tra xem database đã tồn tại hay chưa, tồn tại thì xóa
IF EXISTS (SELECT * FROM sys.databases WHERE name = N'Nhom2new')
BEGIN
    -- Đóng tất cả các kết nối đến cơ sở dữ liệu
    EXECUTE sp_MSforeachdb 'IF ''?'' = ''Nhom2new'' 
    BEGIN 
        DECLARE @sql AS NVARCHAR(MAX) = ''USE [?]; ALTER DATABASE [?] SET SINGLE_USER WITH ROLLBACK IMMEDIATE;''
        EXEC (@sql)
    END'
    -- Xóa tất cả các kết nối tới cơ sở dữ liệu (thực hiện qua hệ thống master)
    USE master;

    -- Xóa cơ sở dữ liệu nếu tồn tại
    DROP DATABASE Nhom2new;
END

-- Tạo cơ sở dữ liệu mới
CREATE DATABASE Nhom2new;
GO

-- Sử dụng cơ sở dữ liệu vừa tạo
USE Nhom2new;
GO

-- Tạo bảng QuocGia
CREATE TABLE QuocGia
(
    maQG CHAR(10) PRIMARY KEY,
    tenQG NVARCHAR(50) not null
);

-- Tạo bảng TinhTP
CREATE TABLE TinhTP
(
    maTP CHAR(10) PRIMARY KEY,
    tenTP NVARCHAR(50) not null ,
    maQG CHAR(10) null,
    CONSTRAINT fk_TinhTP_QuocGia FOREIGN KEY (maQG) REFERENCES QuocGia(maQG) ON UPDATE CASCADE ON DELETE CASCADE
);

-- Tạo bảng QuanHuyen
CREATE TABLE QuanHuyen
(
    maQH CHAR(10) PRIMARY KEY,
    tenQH NVARCHAR(50) not null ,
    maTP CHAR(10) not null,
    CONSTRAINT fk_QuanHuyen_TinhTP FOREIGN KEY (maTP) REFERENCES TinhTP(maTP) ON UPDATE CASCADE ON DELETE CASCADE
);

-- Tạo bảng PhuongXa
CREATE TABLE PhuongXa
(
    maPX CHAR(10) PRIMARY KEY,
    tenPX NVARCHAR(50) not null,
    maQH CHAR(10) not null,
    CONSTRAINT fk_PhuongXa_QuanHuyen FOREIGN KEY (maQH) REFERENCES QuanHuyen(maQH) ON UPDATE CASCADE ON DELETE CASCADE
);

-- Tạo bảng KHACHHANG
CREATE TABLE KHACHHANG
(
    MAKHACHHANG CHAR(9) PRIMARY KEY,
    TENCONGTY NVARCHAR(50) null,
    TENGIAODICH NVARCHAR(50) null,
	DIACHI NVARCHAR(50),
    EMAIL VARCHAR(50) not null,
    DIENTHOAI VARCHAR(11) not null,
    FAX VARCHAR(20) null
);

-- Tạo bảng NHANVIEN
CREATE TABLE NHANVIEN
(
    MANHANVIEN CHAR(9) PRIMARY KEY,
    HO NVARCHAR(10) not null,
    TEN NVARCHAR(30) not null,
    NGAYSINH DATE not null,
    NGAYLAMVIEC DATE not null,
    DIACHI NVARCHAR(50),
    DIENTHOAI VARCHAR(11) not null,
	EMAIL VARCHAR(50),
	FAX CHAR(50) null,
    LUONGCOBAN MONEY null,
    PHUCAP MONEY null,
    CONSTRAINT CK_NHANVIEN_NGAYSINH CHECK (DATEDIFF(YEAR, NGAYSINH, GETDATE()) BETWEEN 18 AND 60)
);

-- Tạo bảng DONDATHANG
CREATE TABLE DONDATHANG
(
    SOHOADON CHAR(9) PRIMARY KEY,
    MAKHACHHANG CHAR(9) not null,
    MANHANVIEN CHAR(9) not null,
    NGAYDATHANG DATE null,
	NGAYCHUYENHANG DATE null,
    NGAYGIAOHANG DATE not null,
    NOIGIAOHANG NVARCHAR(50) not null ,
    CONSTRAINT fk_DONDATHANG_KHACHHANG FOREIGN KEY (MAKHACHHANG) REFERENCES KHACHHANG(MAKHACHHANG)ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT fk_DONDATHANG_NHANVIEN FOREIGN KEY (MANHANVIEN) REFERENCES NHANVIEN(MANHANVIEN)ON UPDATE no action ON DELETE no action,
    CONSTRAINT chk_DONDATHANG_NGAYCHUYENHANG CHECK (NGAYCHUYENHANG >= NGAYDATHANG),
	CONSTRAINT chk_DONDATHANG_NGAYGIAOHANG CHECK (NGAYGIAOHANG >= NGAYCHUYENHANG)
);

-- Tạo bảng NHACUNGCAP
CREATE TABLE NHACUNGCAP
(
    MACONGTY CHAR(10) PRIMARY KEY,
    TENCONGTY NVARCHAR(50) not null ,
	TENGIAODICH NVARCHAR(50) null , 
    DIACHI NVARCHAR(50),
    DIENTHOAI VARCHAR(11) not null,
    FAX VARCHAR(20) null,
    EMAIL NVARCHAR(50) not null
);

-- Tạo bảng LOAIHANG
CREATE TABLE LOAIHANG
(
    MALOAIHANG CHAR(5) PRIMARY KEY,
    TENLOAIHANG NVARCHAR(50) not null
);

-- Tạo bảng MATHANG
CREATE TABLE MATHANG
(
    MAHANG CHAR(5) PRIMARY KEY,
    TENHANG NVARCHAR(50) not null,
    MACONGTY CHAR(10) not null,
    MALOAIHANG CHAR(5) not null,
    SOLUONG INT CHECK (SOLUONG >= 0) not null,
    DONVITINH NVARCHAR(5) DEFAULT N'Cái' null,
    GIAHANG MONEY CHECK (GIAHANG >= 0) not null,
    CONSTRAINT fk_MATHANG_NHACUNGCAP FOREIGN KEY (MACONGTY) REFERENCES NHACUNGCAP(MACONGTY) ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT fk_MATHANG_LOAIHANG FOREIGN KEY (MALOAIHANG) REFERENCES LOAIHANG(MALOAIHANG) ON UPDATE CASCADE ON DELETE CASCADE
);


-- Tạo bảng CHITIETDATHANG
CREATE TABLE CHITIETDATHANG
(
    SOHOADON CHAR(9),
    MAHANG CHAR(5),
    GIABAN MONEY not null CHECK (GIABAN >= 0),
    SOLUONG INT null DEFAULT 1 CHECK (SOLUONG > 0),
    MUCGIAMGIA MONEY null DEFAULT 0,
    PRIMARY KEY (SOHOADON, MAHANG),
    CONSTRAINT fk_CHITIETDATHANG_DONDATHANG FOREIGN KEY (SOHOADON) REFERENCES DONDATHANG(SOHOADON) ,
    CONSTRAINT fk_CHITIETDATHANG_MATHANG FOREIGN KEY (MAHANG) REFERENCES MATHANG(MAHANG)
);

---------------------------------------------------------------------------------------------------------------------------------------------------------------	
--xóa cột địa chỉ
ALTER TABLE KHACHHANG
	DROP COLUMN DIACHI;
-- Thêm cột maPX và soNhaTenDuong vào bảng KHACHHANG
ALTER TABLE KHACHHANG
    ADD maPX CHAR(10) not null,
        soNhaTenDuong NVARCHAR(50) not null ;
-- Thêm ràng buộc khóa ngoại cho maPX trong bảng KHACHHANG
ALTER TABLE KHACHHANG
    ADD CONSTRAINT fk_KhachHang_PhuongXa FOREIGN KEY (maPX) REFERENCES PhuongXa(maPX) ON UPDATE CASCADE ON DELETE CASCADE;
-- Sửa số điện thoại 10 chữ số hoặc 11 chữ số duy nhất trong KhachHang
alter table KHACHHANG
	add constraint chk_KhachHang_SDT check (
	DIENTHOAI like '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]' 
    OR DIENTHOAI like '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]'  ) ;
alter table KHACHHANG
	add constraint uq_KhachHang_SDT unique (DIENTHOAI);
--   bổ sung email có ký tự @ bắt đầu bằng chữ cái   trong bảng KhachHang
alter table KHACHHANG
	add constraint chk_Kh_Email check (EMAIL LIKE '[a-zA-Z]%@%');
alter table KHACHHANG
	add constraint uq_KHACHHANG_Email unique (EMAIL);


--xóa cột địa chỉ
ALTER TABLE NHANVIEN
	DROP COLUMN DIACHI;
-- Thêm cột maPX và soNhaTenDuong vào bảng NHANVIEN
ALTER TABLE NHANVIEN
    ADD maPX CHAR(10) null,
        soNhaTenDuong NVARCHAR(50) null;
-- Thêm ràng buộc khóa ngoại cho maPX trong bảng NHANVIEN
ALTER TABLE NHANVIEN
    ADD CONSTRAINT fk_NhanVien_PhuongXa FOREIGN KEY (maPX) REFERENCES PhuongXa(maPX) ON UPDATE CASCADE ON DELETE CASCADE;
-- Sửa số điện thoại 10 chữ số hoặc 11 chữ số duy nhất trong NhanVien
alter table NHANVIEN
	add constraint chk_NhanVien_SDT check (
    DIENTHOAI like '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]' 
    OR DIENTHOAI like '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]') ;
alter table NHANVIEN
	add constraint uq_NhanVien_SDT unique (DIENTHOAI);
--   bổ sung email có ký tự @ bắt đầu bằng chữ cái   trong bảng NHANVIEN
alter table NHANVIEN
	add constraint chk_KhachHang_Email check (EMAIL LIKE '[a-zA-Z]%@%');
alter table NHANVIEN
	add constraint uq_NhanVien_Email unique (EMAIL);


--xóa cột địa chỉ
ALTER TABLE DONDATHANG
	DROP COLUMN NOIGIAOHANG;
-- Thêm cột maPX và soNhaTenDuong vào bảng NHANVIEN
ALTER TABLE DONDATHANG
    ADD maPX CHAR(10) null,
        soNhaTenDuong NVARCHAR(50) null;
-- ngày tạo đơn hàng bằng ngày hiện tại
alter table  DONDATHANG 
	add constraint  df_DonDatHang_ngayDatHang default  getdate() for NGAYDATHANG;


-- Sửa số điện thoại 10 chữ số hoặc 11 chữ số duy nhất trong NHACUNGCAP
alter table NHACUNGCAP
	add constraint chk_NhaCungCap_SDT check (
	DIENTHOAI like '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]'
	or DIENTHOAI like'[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]') ;
alter table NHACUNGCAP
	add constraint uq_NhaCungCap_SDT unique (DIENTHOAI);
--   bổ sung email có ký tự @ bắt đầu bằng chữ cái trong bảng NHACUNGCAP
alter table NHACUNGCAP
	add constraint chk_NhaCungCap_Email check (EMAIL LIKE '[a-zA-Z]%@%');
alter table NhaCungCap
	add constraint uq_NhaCungCap_Email unique (EMAIL);
--xóa cột địa chỉ
ALTER TABLE NHACUNGCAP
	DROP COLUMN DIACHI
-- Thêm cột maPX và soNhaTenDuong vào bảng NHACUNGCAP
ALTER TABLE NHACUNGCAP
    ADD maPX CHAR(10) not null,
        soNhaTenDuong NVARCHAR(50) not null;
-- Thêm ràng buộc khóa ngoại cho maPX trong bảng NHACUNGCAP
ALTER TABLE NHACUNGCAP
    ADD CONSTRAINT fk_NhaCungCap_PhuongXa FOREIGN KEY (maPX) REFERENCES PhuongXa(maPX)ON UPDATE CASCADE ON DELETE CASCADE;

---------------------------------------------------------------------------------------------------------------------------------------------------------------	
-- Tạo thông tin trong bảng QuocGia
INSERT INTO QuocGia
VALUES 
		('QG00000001', N'Việt Nam');

-- Tạo thông tin trong bảng TinhTP
INSERT INTO TinhTP
VALUES 
		('T000000001', N'Đà Nẵng',null),
		('T000000002', N'Hà Nội',null),
		('T000000003', N'Ninh Bình',null),
		('T000000004', N'Quảng Trị',null),
		('T000000005', N'TP Hồ Chí Minh',null);

-- Tạo thông tin trong bảng QuanHuyen
INSERT INTO QuanHuyen
VALUES 
		('QH00000001', N'Liên Chiểu', 'T000000001'),
		('QH00000002', N'Long Biên', 'T000000002'),
		('QH00000003', N'Kim Sơn', 'T000000003'),
		('QH00000004', N'Gio Linh', 'T000000004'),
		('QH00000005', N'Quận 7', 'T000000005');
-- Tạo thông tin trong bảng PhuongXa
INSERT INTO PhuongXa
VALUES
		('PX00000001', N'Hòa Minh','QH00000001'),
		('PX00000002', N'Ngọc Lâm','QH00000002'),
		('PX00000003', N'Đông Hải','QH00000003'),
		('PX00000004', N'Bắc Sơn','QH00000004'),
		('PX00000005', N'Phường 1','QH00000005');

-- Tạo thông tin trong bảng KHACHHANG
set dateformat dmy
insert into KHACHHANG
values 
		('KH0000001','Aristino','GD001','Aristino@gmail.com','0909090919','fax001','PX00000001',N'15 Lý Thường Kiệt'),
		('KH0000002','5S Fashion','GD002','SFashion@gmail.com','0909090908','fax002','PX00000002',N'20 Lê Đại Hành'),
		('KH0000003','Routine','GD003','Routine@gmail.com','0909090907','fax003','PX00000003',N'100 Điện Biên Phủ'),
		('KH0000004','Coolmate','GD004','Coolmate@gmail.com','0909090906','fax004','PX00000004',N'26 Quang Trung'),
		('KH0000005','Yody','GD005','Yody@gmail.com','0909090905','fax005','PX00000005',N'12 Nguyễn Tất Thành');

-- Tạo thông tin trong bảng NHANVIEN
set dateformat dmy
insert into NHANVIEN
values
		('NV0000001',N'Đặng',N'Công Kiệt','28-10-2005',getdate(),'0101010101','congkiet@gmail.com','fax006',5000000,2000000,'PX00000001',N'12 Điện Biên Phủ'),
		('NV0000002',N'Nguyễn',N'Khánh Ly','12-6-2005',DATEADD(YEAR, -2, GETDATE()),'0101010102','khanhly@gmail.com','fax007',5000000,null,'PX00000002',N'15 Điện Biên Phủ'),
		('NV0000003',N'Nguyễn',N'Khánh Linh','26-10-2005',getdate(),'0101013101','khanhlinh@gmail.com','fax008',5000000,2000000,'PX00000003',N'12 Ông Ích Khiêm'),
		('NV0000004',N'Phạm',N'Huy Hoàng','25-10-2005',DATEADD(YEAR, -1, GETDATE()),'0101010104','huyhoang@gmail.com','fax009',5000000,2000000,'PX00000004',N'23 Nguyễn Tất Thành'),
		('NV0000005',N'Đinh',N'Tiên Hoàng','24-10-2005',getdate(),'0101010181','tienhoang@gmail.com','fax010',5000000,2000000,'PX00000005',N'01 Lê Lợi');

-- Tạo thông tin trong bảng LOAIHANG
insert into LOAIHANG
values 
		('LH001',N'Quần'),
		('LH002',N'Áo'),
		('LH003',N'Túi xách'),
		('LH004',N'Khăn'),
		('LH005',N'Giày');

-- Tạo thông tin trong bảng DONDATHANG
set dateformat dmy
insert into DONDATHANG
values 
		('HD0000001','KH0000001','NV0000001',default,null,getdate()+4,'PX00000001',NULL),
		('HD0000002','KH0000001','NV0000002',default,null,getdate()+4,'PX00000002',NULL),
		('HD0000003','KH0000003','NV0000001',default,getdate()+3,getdate()+4,'PX00000001',N'12 Lý Thường Kiệt'),
		('HD0000004','KH0000004','NV0000004',default,getdate()+2,getdate()+4,'PX00000004',N'26 Quang Trung'),
		('HD0000005','KH0000005','NV0000005',default,getdate()+1,getdate()+4,'PX00000003',N'66 Điện Biên Phủ');

-- Tạo thông tin trong bảng NHACUNGCAP
INSERT INTO NHACUNGCAP
VALUES
		('CT00000001',N'Aristino','GD001','0123456789',null,'Aristino@gmail.com','PX00000001', N'23 Nguyễn Tất Thành'),
		('CT00000005',N'5S Fashion','GD002','0113456789',null,'Bristino@gmail.com','PX00000001', N'24 Nguyễn Tất Thành'),
		('CT00000002',N'Công ty B','GD003','0121456789',null,'Gristino@gmail.com','PX00000002', N'15 Lý Thường Kiệt'),
		('CT00000003',N'Công ty C','GD004','0123156789',null,'Dristino@gmail.com','PX00000003', N'26 Quang Trung'),
		('CT00000004',N'Công ty D','GD005','0123416789',null,'Eristino@gmail.com','PX00000004', N'66 Điện Biên Phủ');

-- Tạo thông tin trong bảng MATHANG
insert into MATHANG
values 
		('MH001',N'Quần jeans','CT00000001','LH001',50,default,5000000),
		('MH002',N'Áo phông','CT00000001','LH002',40,default,2000000),
		('MH003',N'Quần jeans','CT00000002','LH001',60,default,4800000),
		('MH004',N'Giày thể thao','CT00000003','LH005',20,default,3000000),
		('MH005',N'Quần đùi','CT00000003','LH001',30,default,1200000);

-- Tạo thông tin trong bảng CHITIETDATHANG
insert into CHITIETDATHANG
values 
		('HD0000001','MH001',500000,5,default),
		('HD0000001','MH002',250000,5,default),
		('HD0000003','MH002',450000,10,default),
		('HD0000004','MH004',300000,2,10000),
		('HD0000005','MH005',40000,20,10000);

---------------------------------------------------------------------------------------------------------------------------------------------------------------		
/*--a) Cập nhật lại giá trị trường NGAYCHUYENHANG của những bản ghi 
--có NGAYCHUYENHANG chưa xác định (NULL) trong bảng DONDATHANG bằng với giá trị của trường NGAYDATHANG.
update DONDATHANG
	set NGAYCHUYENHANG = NGAYDATHANG
	where NGAYCHUYENHANG is NULL
--select * from DONDATHANG
--b) Tăng số lượng hàng của những mặt hàng do công ty Aristino cung cấp lên gấp đôi.
update MATHANG
	set SOLUONG = SOLUONG*2
	from NHACUNGCAP
	where NHACUNGCAP.MACONGTY = MATHANG.MACONGTY
		and TENCONGTY = N'Aristino'
/*select * 
from MATHANG m, NHACUNGCAP ncc
where m.MACONGTY=ncc.MACONGTY*/
--c) Cập nhật giá trị của trường soNhaTenDuong trong bảng DONDATHANG bằng địa chỉ của 
--khách hàng đối với những đơn đặt hàng chưa xác định được nơi giao hàng (giá trị trường soNhaTenDuong bằng NULL).
UPDATE DONDATHANG
set DONDATHANG.soNhaTenDuong = KHACHHANG.soNhaTenDuong
from KHACHHANG
where 
	KHACHHANG.MAKHACHHANG = DONDATHANG.MAKHACHHANG and
	DONDATHANG.soNhaTenDuong is NULL
/*select * 
from DONDATHANG, KHACHHANG
where KHACHHANG.MAKHACHHANG = DONDATHANG.MAKHACHHANG*/
--d) Cập nhật lại dữ liệu trong bảng KHACHHANG sao cho nếu tên công ty và tên giao dịch của 
--khách hàng trùng với tên công ty và tên giao dịch của một nhà cung cấp nào đó thì 
--địa chỉ, điện thoại, fax và e-mail phải giống nhau.
UPDATE KHACHHANG
SET 
    KHACHHANG.DIENTHOAI = NHACUNGCAP.DIENTHOAI,
    KHACHHANG.FAX = NHACUNGCAP.FAX,
    KHACHHANG.EMAIL = NHACUNGCAP.EMAIL,
    KHACHHANG.maPX = NHACUNGCAP.maPX,
	KHACHHANG.soNhaTenDuong = NHACUNGCAP.soNhaTenDuong
FROM 
    KHACHHANG, NHACUNGCAP
WHERE 
    KHACHHANG.TENCONGTY = NHACUNGCAP.TENCONGTY AND
    KHACHHANG.TENGIAODICH = NHACUNGCAP.TENGIAODICH;
--e) Tăng lương lên gấp rưỡi cho những nhân viên bán được số lượng hàng nhiều hơn 8 trong năm 2024.
update NHANVIEN
	set LUONGCOBAN = LUONGCOBAN *1.5
	where MANHANVIEN in (
		select n.MANHANVIEN
		from NHANVIEN n , DONDATHANG d, CHITIETDATHANG c
		where
			n.MANHANVIEN = d.MANHANVIEN and
			d.SOHOADON = c.SOHOADON and
			year(NGAYDATHANG) = '2024'
		group by n.MANHANVIEN
		having SUM(SOLUONG) > 8
	)
--select * from NHANVIEN
--f) Tăng phụ cấp lên bằng 50% lương cho những nhân viên bán được hàng nhiều nhất.
update NHANVIEN
	set PHUCAP = LUONGCOBAN/2
	where MANHANVIEN in (
		select top 1 with ties n.MANHANVIEN
		from NHANVIEN n, DONDATHANG d, CHITIETDATHANG c
		where 
			n.MANHANVIEN = d.MANHANVIEN 
		and d.SOHOADON = c.SOHOADON
		group by n.MANHANVIEN
		order by SUM(SOLUONG) desc
	)
--select * from NHANVIEN

--g) Giảm 25% lương của những nhân viên trong năm 2024 không lập được bất kỳ đơn đặt hàng nào.
UPDATE NHANVIEN
SET LUONGCOBAN = LUONGCOBAN * 0.75
WHERE MANHANVIEN NOT IN (
    SELECT MANHANVIEN
    FROM DONDATHANG
    WHERE YEAR(NGAYDATHANG) = 2024
);
--select * from NHANVIEN */

---------------------------------------------------------------------------------------------------------------------------------------------------------------
/*--1.Cho biết danh sách các đối tác cung cấp hàng cho công ty
select *
from NHACUNGCAP

--2.Mã hàng, tên hàng và số lượng của các mặt hàng hiện có trong công ty.
select MAHANG, TENHANG, SOLUONG
from MATHANG

--3.Họ tên và địa chỉ và năm bắt đầu làm việc của các nhân viên trong công ty
select MANHANVIEN,CONCAT(HO, ' ', TEN) AS HovaTen,maPX,soNhaTenDuong,YEAR(NGAYLAMVIEC) as NamBĐLamViec
from NHANVIEN 

--4.Địa chỉ và điện thoại của nhà cung cấp có tên giao dịch [VINAMILK]  là gì?
update NHACUNGCAP
set TENGIAODICH='VINAMILK'
where MACONGTY='CT00000003'
select TENGIAODICH,soNhaTenDuong,DIENTHOAI
from NHACUNGCAP 
where TENGIAODICH='VINAMILK'

--5.	Cho biết mã và tên của các mặt hàng có giá lớn hơn 100000 và số lượng hiện có ít hơn 50.
SELECT 
    MAHANG, 
    TENHANG, 
    SOLUONG, 
    FORMAT(GIAHANG, 'N0', 'vi-VN') + ' VND' AS GIAHANG_VND
FROM 
    MATHANG
WHERE 
    SOLUONG < 50 
    AND GIAHANG > 100000;

--6.	Cho biết mỗi mặt hàng trong công ty do ai cung cấp
select ncc.TENCONGTY, m.TENHANG
from MATHANG m
join NHACUNGCAP ncc on m.MACONGTY=ncc.MACONGTY

--7.	Công ty [Việt Tiến] đã cung cấp những mặt hàng nào?
update NHACUNGCAP
set TENCONGTY=N'Viet Tien'
where MACONGTY='CT00000003'
select ncc.TENCONGTY, m.MAHANG, m.TENHANG
from NHACUNGCAP ncc
join MATHANG m on ncc.MACONGTY=m.MACONGTY
where TENCONGTY=N'Viet Tien'

--8.	Loại hàng thực phẩm do những công ty nào cung cấp và địa chỉ của các công ty đó là gì?
update LOAIHANG
set TENLOAIHANG= N'Thực phẩm'
where MALOAIHANG='LH001'
select distinct ncc.TENCONGTY, ncc.soNhaTenDuong
from NHACUNGCAP ncc
join MATHANG m on m.MACONGTY=ncc.MACONGTY
join LOAIHANG l on m.MALOAIHANG=l.MALOAIHANG
where l.TENLOAIHANG= N'Thực phẩm'

--9.	Những khách hàng nào (tên giao dịch) đã đặt mua mặt hàng Sữa hộp XYZ của công ty?
update MATHANG
set TENHANG = N'Sữa hộp XYZ'
where MAHANG = 'MH002'

select distinct TENGIAODICH, TENHANG
from KHACHHANG k
join DONDATHANG d on d.MAKHACHHANG = k.MAKHACHHANG
join CHITIETDATHANG c on c.SOHOADON = d.SOHOADON
join MATHANG m on m.MAHANG = c.MAHANG
where TENHANG = N'Sữa hộp XYZ'

--10.	Đơn đặt hàng số 1 do ai đặt và do nhân viên nào lập, thời gian và địa điểm giao hàng là ở đâu?
select TEN [tên nhân viên], k.TENCONGTY [tên khách hàng], NGAYGIAOHANG[thời gian giao hàng], d.soNhaTenDuong [địa điểm]
from NHANVIEN n
	join DONDATHANG d on n.MANHANVIEN = d.MANHANVIEN
	join KHACHHANG k on d.MAKHACHHANG = k.MAKHACHHANG
where SOHOADON = 'HD0000001'

--11.	Hãy cho biết số tiền lương mà công ty phải trả cho mỗi nhân viên là bao nhiêu (lương = lương cơ bản + phụ cấp).
SELECT 
    ten AS [Tên Nhân Viên], 
    FORMAT(LUONGCOBAN + coalesce(PHUCAP,0), 'N0', 'vi-VN') + ' VND' AS [Lương]
FROM 
    NHANVIEN;

--12.	Hãy cho biết có những khách hàng nào lại chính là đối tác cung cấp hàng của công ty (tức là có cùng tên giao dịch).
select n.TENCONGTY as N'tên công ty cung cấp', k.TENCONGTY N'tên công ty khách hàng'
from NHACUNGCAP n, KHACHHANG k
where
	n.TENGIAODICH = k.TENGIAODICH

--13.	Trong công ty có những nhân viên nào có cùng ngày sinh?
set dateformat dmy
update NHANVIEN
set NGAYSINH = '28/10/2005'
where NGAYSINH = '24/10/2005'

SELECT NV1.MANHANVIEN, CONCAT(NV1.HO, ' ', NV1.TEN) AS HoTen
FROM NHANVIEN NV1
JOIN NHANVIEN NV2 ON NV1.NGAYSINH = NV2.NGAYSINH
WHERE NV1.MANHANVIEN <> NV2.MANHANVIEN;

-- 14. Những đơn đặt hàng nào yêu cầu giao hàng ngay tại công ty đặt hàng và những đơn đó là của công ty nào?
SELECT dh.SOHOADON, kh.TENCONGTY
FROM DONDATHANG dh
JOIN KHACHHANG kh ON dh.MAKHACHHANG = kh.MAKHACHHANG
WHERE dh.soNhaTenDuong = kh.soNhaTenDuong;

-- 15. Tên công ty, tên giao dịch, địa chỉ và điện thoại của các khách hàng và nhà cung cấp
SELECT TENCONGTY, TENGIAODICH, soNhaTenDuong, DIENTHOAI
FROM KHACHHANG
UNION
SELECT TENCONGTY, TENGIAODICH, soNhaTenDuong, DIENTHOAI
FROM NHACUNGCAP;

-- 16. Những mặt hàng nào chưa từng được khách hàng đặt mua
SELECT 
    mh.MAHANG,
    mh.TENHANG,
    mh.SOLUONG,
    FORMAT(mh.GIAHANG, 'N0', 'vi-VN') + ' VND' AS GIAHANG
FROM 
    MATHANG mh
WHERE 
    mh.MAHANG NOT IN (SELECT ctdh.MAHANG FROM CHITIETDATHANG ctdh);

-- 17. Những nhân viên nào của công ty chưa từng lập bất kỳ một hoá đơn đặt hàng nào
SELECT NV.*
FROM NHANVIEN NV
WHERE NV.MANHANVIEN NOT IN (SELECT MANHANVIEN FROM DONDATHANG);

-- 18. Những nhân viên nào có lương cơ bản cao nhất
SELECT 
    NV.MANHANVIEN,NV.HO, NV.TEN,
    FORMAT(NV.LUONGCOBAN, 'N0', 'vi-VN') + ' VND' AS LUONGCOBAN
FROM 
    NHANVIEN NV
WHERE 
    NV.LUONGCOBAN = (SELECT MAX(LUONGCOBAN) FROM NHANVIEN); */

---------------------------------------------------------------------------------------------------------------------------------------------------------------
/*Câu 1: Tạo thủ tục lưu trữ để thông qua thủ tục này có thể bổ sung thêm một bản ghi mới cho bảng MATHANG 
(thủ tục phải thực hiện kiểm tra tính hợp lệ của dữ liệu cần bổ sung: không trùng khoá chính và đảm bảo toàn vẹn tham chiếu) */
GO
CREATE PROCEDURE ThemMatHang
    @MAHANG CHAR(5),
    @TENHANG NVARCHAR(50),
    @MACONGTY CHAR(10),
    @MALOAIHANG CHAR(5),
    @SOLUONG INT,
    @DONVITINH NVARCHAR(5),
    @GIAHANG MONEY
AS
BEGIN
    -- Kiểm tra nếu MAHANG đã tồn tại
    IF EXISTS (SELECT 1 FROM MATHANG WHERE MAHANG = @MAHANG)
    BEGIN
        PRINT N'Error: MAHANG đã tồn tại.';
        RETURN;
    END

    -- Kiểm tra nếu MACONGTY tồn tại trong bảng NHACUNGCAP
    IF NOT EXISTS (SELECT 1 FROM NHACUNGCAP WHERE MACONGTY = @MACONGTY)
    BEGIN
        PRINT N'Error: MACONGTY không tồn tại trong bảng NHACUNGCAP.';
        RETURN;
    END

    -- Kiểm tra nếu MALOAIHANG tồn tại trong bảng LOAIHANG
    IF NOT EXISTS (SELECT 1 FROM LOAIHANG WHERE MALOAIHANG = @MALOAIHANG)
    BEGIN
        PRINT N'Error: MALOAIHANG không tồn tại trong bảng LOAIHANG.';
        RETURN;
    END

    -- Chèn bản ghi mới vào bảng MATHANG
    INSERT INTO MATHANG (MAHANG, TENHANG, MACONGTY, MALOAIHANG, SOLUONG, DONVITINH, GIAHANG)
    VALUES (@MAHANG, @TENHANG, @MACONGTY, @MALOAIHANG, @SOLUONG, @DONVITINH, @GIAHANG);

    PRINT N'Bản ghi mới đã được thêm thành công.';
END;
GO
EXEC ThemMatHang 
    @MAHANG = 'MH006', 
    @TENHANG = N'Sản phẩm MINI', 
    @MACONGTY = 'CT00000005', 
    @MALOAIHANG = 'LH002', 
    @SOLUONG = 200, 
    @DONVITINH = N'Hộp', 
    @GIAHANG = 750000;

SELECT * FROM MATHANG

/*Câu 2: Tạo thủ tục lưu trữ có chức năng thống kê tổng số lượng hàng bán được của một mặt hàng
có mã bất kỳ (mã mặt hàng cần thống kê là tham số của thủ tục). */
GO
ALTER TABLE DONDATHANG
ADD TRANGTHAIDONHANG NVARCHAR(30);
GO
UPDATE DONDATHANG
SET TRANGTHAIDONHANG = N'Thành công';

GO
CREATE PROCEDURE pr_ThongKeSoLuongHangBanDuoc
    @MaHang CHAR(5)
AS
BEGIN
    SELECT 
        C.MaHang, 
        SUM(C.SoLuong) AS TongSoLuongBan
    FROM 
        CHITIETDATHANG C
        JOIN DONDATHANG D ON C.SOHOADON = D.SOHOADON
    WHERE 
        C.MaHang = @MaHang
        AND D.TRANGTHAIDONHANG = N'Thành công'
    GROUP BY 
        C.MaHang
END
GO

EXEC pr_ThongKeSoLuongHangBanDuoc @MaHang = N'MH002';

/*Câu 3: Viết hàm trả về một bảng trong đó cho biết tổng số lượng hàng bán được của mỗi mặt hàng. 
Sử dụng hàm này để thống kê xem tổng số lượng hàng (hiện có và đã bán) của mỗi mặt hàng là bao nhiêu.*/
go
CREATE FUNCTION fn_SoLuongHang()
RETURNS TABLE
AS
RETURN 
(
    SELECT 
        m.MAHANG, 
        m.TENHANG,
        ISNULL(SUM(c.SOLUONG), 0) AS SOLUONGDABAN, 
        MAX(m.SOLUONG) AS SOLUONGTRONGKHO, 
        MAX(m.SOLUONG) - ISNULL(SUM(c.SOLUONG), 0) AS SOLUONGHIENCON
    FROM 
        MATHANG m
    LEFT JOIN CHITIETDATHANG as c on c.MAHANG=m.MAHANG
    GROUP BY m.MAHANG, m.TENHANG
)
go
SELECT * FROM fn_SoLuongHang()

--Câu 4: Viết trigger cho bảng CHITIETDATHANG theo yêu cầu sau:
/*a) Khi một bản ghi mới được bổ sung vào bảng này thì giảm số lượng hàng hiện có 
nếu số lượng hàng hiện có lớn hơn hoặc bằng số lượng hàng được bán ra. 
Ngược lại thì huỷ bỏ thao tác bổ sung*/
GO
CREATE TRIGGER trg_InsertChiTietDatHang
ON CHITIETDATHANG
INSTEAD OF INSERT
AS
BEGIN
    DECLARE @MAHANG CHAR(5), @SOLUONG INT;

    -- Lấy giá trị từ bản ghi mới
    SELECT @MAHANG = MAHANG, @SOLUONG = SOLUONG FROM inserted;

    -- Kiểm tra số lượng hàng hiện có
    DECLARE @SoLuongHienCo INT;
    SELECT @SoLuongHienCo = SOLUONG FROM MATHANG WHERE MAHANG = @MAHANG;

    -- Nếu số lượng hàng hiện có lớn hơn hoặc bằng số lượng bán ra
    IF @SoLuongHienCo >= @SOLUONG
    BEGIN
        -- Giảm số lượng hàng hiện có
        UPDATE MATHANG
        SET SOLUONG = SOLUONG - @SOLUONG
        WHERE MAHANG = @MAHANG;

        -- Thêm bản ghi mới vào bảng CHITIETDATHANG
        INSERT INTO CHITIETDATHANG (SOHOADON, MAHANG, GIABAN, SOLUONG, MUCGIAMGIA)
        SELECT SOHOADON, MAHANG, GIABAN, SOLUONG, MUCGIAMGIA FROM inserted;
    END
    ELSE
    BEGIN
        -- Huỷ bỏ thao tác bổ sung
        PRINT N'Thao tác bổ sung bị huỷ bỏ: Số lượng hàng bán ra vượt quá số lượng hiện có!';
    END
END;
GO
CREATE TRIGGER trg_DeleteChiTietDatHang
ON CHITIETDATHANG
AFTER DELETE
AS
BEGIN
    -- Khôi phục số lượng hàng trong bảng MATHANG
    UPDATE MATHANG
    SET SOLUONG = MATHANG.SOLUONG + d.SOLUONG
    FROM deleted d
    WHERE MATHANG.MAHANG = d.MAHANG;
END;
GO

CREATE TRIGGER trg_DeleteDonDatHang
ON DONDATHANG
AFTER DELETE
AS
BEGIN
    -- Khôi phục số lượng hàng trong bảng MATHANG từ CHITIETDATHANG
    UPDATE MATHANG
    SET SOLUONG = MATHANG.SOLUONG + c.SOLUONG
    FROM deleted d
    JOIN CHITIETDATHANG c ON d.SOHOADON = c.SOHOADON
    WHERE MATHANG.MAHANG = c.MAHANG;
END;
GO
select * from MATHANG
select * from DONDATHANG
select* from CHITIETDATHANG

--thực thi a
INSERT INTO DONDATHANG (SOHOADON, MAKHACHHANG, MANHANVIEN, NGAYDATHANG, NGAYCHUYENHANG, NGAYGIAOHANG, maPX, soNhaTenDuong)
VALUES ('HD0000006', 'KH0000005', 'NV0000001', GETDATE(), GETDATE() + 1, GETDATE() + 3, 'PX00000004', N'24 Quang Trung');
INSERT INTO CHITIETDATHANG (SOHOADON, MAHANG, GIABAN, SOLUONG, MUCGIAMGIA)
VALUES ('HD0000006', 'MH001', 100000, 5, 1000);
 -- bổ sung 
 ALTER TABLE CHITIETDATHANG
DROP CONSTRAINT fk_CHITIETDATHANG_DONDATHANG;

ALTER TABLE CHITIETDATHANG
ADD CONSTRAINT fk_CHITIETDATHANG_DONDATHANG FOREIGN KEY (SOHOADON) 
REFERENCES DONDATHANG(SOHOADON) ON DELETE CASCADE;
/*
-- Xóa chi tiết đơn hàng
DELETE FROM CHITIETDATHANG
WHERE SOHOADON = 'HD0000006';
 */
-- Xóa đơn hàng
GO
DELETE FROM DONDATHANG
WHERE SOHOADON = 'HD0000006'; 

/*b) Khi cập nhật lại số lượng hàng được bán, kiểm tra số lượng hàng được cập nhật lại có phù hợp hay không 
(số lượng hàng bán ra không được vượt quá số lượng hàng hiện có và không được nhỏ hơn 1). 
Nếu dữ liệu hợp lệ thì giảm (hoặc tăng) số lượng hàng hiện có trong công ty, 
ngược lại thì huỷ bỏ thao tác cập nhật.*/
go
create trigger UPDATE_CHITIETDATHANG
on CHITIETDATHANG
instead of update
as
begin
	if exists
	(
		select *
		from inserted i ,deleted d, MATHANG m
		where 
			i.MAHANG = m.MAHANG and
			m.MAHANG = d.MAHANG and
			(i.SOLUONG > (d.SOLUONG + m.SOLUONG) or i.SOLUONG < 1)
	)
	begin
		print(N'Cập nhật không hợp lệ');
		return;
	end
	
	update CHITIETDATHANG
	set SOLUONG = i.SOLUONG
	from inserted i
	where CHITIETDATHANG.SOHOADON = i.SOHOADON

	update MATHANG 
	set MATHANG.SOLUONG = MATHANG.SOLUONG + d.SOLUONG - i.SOLUONG
	from inserted i , deleted d
	where
		i.MAHANG = MATHANG.MAHANG and
		MATHANG.MAHANG = d.MAHANG

end
go
select * from CHITIETDATHANG
select * from MATHANG

update CHITIETDATHANG
set SOLUONG = 5
where SOHOADON = 'HD0000001'

