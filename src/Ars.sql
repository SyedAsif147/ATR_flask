-- phpMyAdmin SQL Dump
-- version 4.8.5
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1:3306
-- Generation Time: Dec 02, 2020 at 11:03 AM
-- Server version: 5.7.26
-- PHP Version: 7.2.18

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET AUTOCOMMIT = 0;
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `airlines`
--
CREATE DATABASE IF NOT EXISTS `airlines` DEFAULT CHARACTER SET latin1 COLLATE latin1_swedish_ci;
USE `airlines`;

-- --------------------------------------------------------

--
-- Table structure for table `airplane`
--

DROP TABLE IF EXISTS `airplane`;
CREATE TABLE IF NOT EXISTS `airplane` (
  `model_id` int(11) NOT NULL,
  `company` varchar(20) NOT NULL,
  `type` varchar(10) NOT NULL,
  PRIMARY KEY (`model_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `airplane`
--

INSERT INTO `airplane` (`model_id`, `company`, `type`) VALUES
(1236, 'Airbus', 'A380'),
(1562, 'Boeing', '737');

-- --------------------------------------------------------

--
-- Table structure for table `airport`
--

DROP TABLE IF EXISTS `airport`;
CREATE TABLE IF NOT EXISTS `airport` (
  `city_id` varchar(11) NOT NULL,
  `city_name` varchar(11) NOT NULL,
  `airport` varchar(50) NOT NULL,
  PRIMARY KEY (`city_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `airport`
--

INSERT INTO `airport` (`city_id`, `city_name`, `airport`) VALUES
('BLR', 'Bangalore', 'Kempegowda International Airport'),
('CCU', 'Kolkata', 'Netaji Subhash Chandra Bose International Airport'),
('COK', 'Kochin', 'Cochin International Airport'),
('DEL', 'Dehli', 'Indira Gandhi International Airport'),
('HBX', 'Hubli', 'Hubli Airport');

-- --------------------------------------------------------

--
-- Table structure for table `booking`
--

DROP TABLE IF EXISTS `booking`;
CREATE TABLE IF NOT EXISTS `booking` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `flight_no` varchar(10) NOT NULL,
  `passenger_fname` varchar(30) NOT NULL,
  `passenger_mname` varchar(30) DEFAULT NULL,
  `passenger_lname` varchar(30) DEFAULT NULL,
  `age` int(11) NOT NULL,
  `gender` enum('male','female','other') NOT NULL,
  `type` enum('DIS','ADT') NOT NULL,
  `class_type` enum('Economy','Business') NOT NULL,
  `booking_time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `payment` tinyint(1) NOT NULL,
  `booked_by` varchar(30) NOT NULL,
  PRIMARY KEY (`id`,`flight_no`,`passenger_fname`,`age`),
  KEY `passenger_fk` (`passenger_fname`),
  KEY `flight_class_fk` (`flight_no`,`class_type`),
  KEY `user_fk` (`booked_by`)
) ENGINE=InnoDB AUTO_INCREMENT=45 DEFAULT CHARSET=latin1;

--
-- Dumping data for table `booking`
--

INSERT INTO `booking` (`id`, `flight_no`, `passenger_fname`, `passenger_mname`, `passenger_lname`, `age`, `gender`, `type`, `class_type`, `booking_time`, `payment`, `booked_by`) VALUES
(1, 'AA008', 'Dinosaur', NULL, NULL, 26, 'male', 'DIS', 'Business', '2019-11-15 21:07:39', 2, 'kent'),
(3, 'AA008', 'sheldon', NULL, NULL, 32, 'male', 'DIS', 'Business', '2019-11-17 18:32:55', 1, 'kent'),
(5, 'AA008', 'polar', NULL, NULL, 32, 'male', 'DIS', 'Business', '2019-11-17 19:23:38', 1, 'kent'),
(8, 'AA444', 'Kushwanth_P', NULL, NULL, 37, 'male', 'DIS', 'Economy', '2019-11-17 19:38:42', 2, 'kent'),
(16, 'AC430', 'sanjana', NULL, NULL, 21, 'male', 'ADT', 'Business', '2019-11-18 04:24:32', 1, 'kent'),
(37, 'AA100', 'porcupine', 'p', 'kju', 46, 'male', 'DIS', 'Economy', '2019-12-02 16:35:18', 2, 'kent'),
(40, 'AA100', 'megha', 'v', 's', 21, 'female', 'ADT', 'Economy', '2019-12-02 16:46:35', 2, 'sanju'),
(41, 'AA204', 'abdfes', 'g', 'beldale', 34, 'female', 'ADT', 'Business', '2019-12-02 16:56:20', 2, 'kent'),
(42, 'AA204', 'gagan', 'g', 'r', 45, 'male', 'ADT', 'Business', '2019-12-02 17:10:14', 2, 'kent'),
(43, 'AA200', 'porcupine', 'fr', 'beldale', 34, 'female', 'ADT', 'Economy', '2019-12-02 17:16:47', 2, 'kent'),
(44, 'AA510', 'gagan', 'p', 's', 45, 'male', 'ADT', 'Business', '2019-12-03 07:39:55', 2, 'sanju');

--
-- Triggers `booking`
--
DROP TRIGGER IF EXISTS `seats`;
DELIMITER $$
CREATE TRIGGER `seats` BEFORE INSERT ON `booking` FOR EACH ROW BEGIN
declare cc,seats int;

SET cc=(SELECT count(*) FROM `booking` where flight_no=NEW.flight_no AND class_type=NEW.class_type);
set seats=(SELECT capacity FROM `class` WHERE flight_no=NEW.flight_no and class=NEW.class_type);
if(cc=seats) then
signal sqlstate '45000';
end if;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `class`
--

DROP TABLE IF EXISTS `class`;
CREATE TABLE IF NOT EXISTS `class` (
  `flight_no` varchar(10) NOT NULL,
  `class` enum('Business','Economy') NOT NULL,
  `capacity` int(11) NOT NULL,
  `price` int(11) NOT NULL,
  PRIMARY KEY (`flight_no`,`class`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `class`
--

INSERT INTO `class` (`flight_no`, `class`, `capacity`, `price`) VALUES
('AA008', 'Business', 5, 43740),
('AA008', 'Economy', 200, 4210),
('AA100', 'Business', 15, 27870),
('AA100', 'Economy', 190, 4740),
('AA120', 'Business', 20, 55322),
('AA120', 'Economy', 200, 8398),
('AA150', 'Business', 4, 76862),
('AA150', 'Economy', 100, 12260),
('AA200', 'Business', 10, 9450),
('AA200', 'Economy', 200, 40100),
('AA204', 'Business', 5, 40025),
('AA204', 'Economy', 180, 7435),
('AA340', 'Business', 8, 33984),
('AA340', 'Economy', 200, 10389),
('AA390', 'Business', 8, 60148),
('AA390', 'Economy', 150, 4498),
('AA444', 'Business', 5, 29758),
('AA444', 'Economy', 200, 2954),
('AA509', 'Business', 9, 76905),
('AA509', 'Economy', 160, 11148),
('AA510', 'Business', 5, 27200),
('AA510', 'Economy', 150, 4720),
('AA919', 'Business', 7, 38120),
('AA919', 'Economy', 200, 6520),
('AC400', 'Business', 6, 57680),
('AC400', 'Economy', 160, 4498),
('AC430', 'Business', 5, 81350),
('AC430', 'Economy', 160, 13148),
('AC800', 'Business', 20, 55320),
('AC800', 'Economy', 210, 9622),
('AD102', 'Business', 5, 27867),
('AD102', 'Economy', 190, 4965),
('AD989', 'Business', 20, 38120),
('AD989', 'Economy', 200, 695);

-- --------------------------------------------------------

--
-- Table structure for table `demo`
--

DROP TABLE IF EXISTS `demo`;
CREATE TABLE IF NOT EXISTS `demo` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `cc` varchar(50) NOT NULL,
  `seats` varchar(10) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM AUTO_INCREMENT=7 DEFAULT CHARSET=latin1;

--
-- Dumping data for table `demo`
--

INSERT INTO `demo` (`id`, `cc`, `seats`) VALUES
(4, '4', '5'),
(3, '3', '5'),
(5, '5', '5'),
(6, '5', '200');

-- --------------------------------------------------------

--
-- Table structure for table `flights`
--

DROP TABLE IF EXISTS `flights`;
CREATE TABLE IF NOT EXISTS `flights` (
  `number` varchar(11) NOT NULL,
  `airplane_id` int(11) NOT NULL,
  `airlines` varchar(30) NOT NULL,
  `departure` varchar(10) NOT NULL,
  `d_time` time NOT NULL,
  `arrival` varchar(10) NOT NULL,
  `a_time` time NOT NULL,
  PRIMARY KEY (`number`),
  KEY `airplane_id` (`airplane_id`),
  KEY `departure_fk` (`departure`),
  KEY `arrival_fk` (`arrival`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `flights`
--

INSERT INTO `flights` (`number`, `airplane_id`, `airlines`, `departure`, `d_time`, `arrival`, `a_time`) VALUES
('AA008', 1562, 'Air India', 'BLR', '13:00:00', 'COK', '16:12:00'),
('AA010', 1562, 'SpiceJet', 'BLR', '11:00:00', 'COK', '14:12:00'),
('AA100', 1236, 'SpiceJet', 'BLR', '18:35:00', 'HBX', '19:45:00'),
('AA120', 1236, 'Air India', 'BLR', '20:00:00', 'CCU', '22:30:00'),
('AA150', 1562, 'SpiceJet', 'HBX', '17:00:00', 'DEL', '23:20:00'),
('AA200', 1236, 'IndiGo', 'DEL', '11:00:00', 'BLR', '14:00:00'),
('AA204', 1562, 'Qantas', 'BLR', '10:00:00', 'DEL', '12:45:00'),
('AA306', 1562, 'SpiceJet', 'DEL', '09:00:00', 'BLR', '12:00:00'),
('AA340', 1562, 'IndiGo', 'DEL', '04:00:00', 'COK', '05:00:00'),
('AA390', 1562, 'Air India', 'COK', '03:00:00', 'HBX', '05:00:00'),
('AA444', 1562, 'SpiceJet', 'BLR', '15:00:00', 'CCU', '17:30:00'),
('AA455', 1562, 'Qantas', 'BLR', '17:00:00', 'CCU', '19:30:00'),
('AA480', 1236, 'Air India', 'DEL', '20:00:00', 'BLR', '23:00:00'),
('AA500', 1236, 'Air India', 'BLR', '12:35:00', 'DEL', '15:20:00'),
('AA509', 1562, 'Qantas', 'DEL', '07:00:00', 'HBX', '13:00:00'),
('AA510', 1236, 'SpiceJet', 'HBX', '18:00:00', 'BLR', '19:00:00'),
('AA919', 1236, 'IndiGo', 'DEL', '22:00:00', 'CCU', '00:20:00'),
('AC100', 1562, 'IndiGo', 'BLR', '01:00:00', 'DEL', '03:45:00'),
('AC400', 1236, 'Qantas', 'HBX', '03:00:00', 'COK', '04:50:00'),
('AC430', 1236, 'SpiceJet', 'HBX', '15:00:00', 'CCU', '20:55:00'),
('AC800', 1236, 'Air India', 'CCU', '15:00:00', 'BLR', '17:40:00'),
('AD102', 1236, 'IndiGo', 'COK', '11:00:00', 'BLR', '12:05:00'),
('AD989', 1236, 'Qantas', 'CCU', '07:00:00', 'DEL', '09:35:00'),
('AE987', 1562, 'Qantas', 'CCU', '03:40:00', 'BLR', '06:20:00');

-- --------------------------------------------------------

--
-- Table structure for table `ticket`
--

DROP TABLE IF EXISTS `ticket`;
CREATE TABLE IF NOT EXISTS `ticket` (
  `ticket_id` int(11) NOT NULL AUTO_INCREMENT,
  `flight_no` varchar(30) NOT NULL,
  `airlines` varchar(30) NOT NULL,
  `class` enum('Economy','Business') NOT NULL,
  `date` varchar(20) NOT NULL,
  `time` varchar(30) NOT NULL,
  `price` int(11) NOT NULL,
  `fname` varchar(30) NOT NULL,
  `mname` varchar(30) DEFAULT NULL,
  `lname` varchar(30) DEFAULT NULL,
  `gender` enum('male','female') NOT NULL,
  `seat_no` varchar(30) NOT NULL,
  `book_id` int(11) NOT NULL,
  PRIMARY KEY (`ticket_id`),
  KEY `booking_book_id` (`book_id`)
) ENGINE=InnoDB AUTO_INCREMENT=31 DEFAULT CHARSET=latin1;

--
-- Dumping data for table `ticket`
--

INSERT INTO `ticket` (`ticket_id`, `flight_no`, `airlines`, `class`, `date`, `time`, `price`, `fname`, `mname`, `lname`, `gender`, `seat_no`, `book_id`) VALUES
(3, 'AA008', 'Air India', 'Business', '2019-11-16 ', '13:00:00', 43740, 'Dinosaur', NULL, NULL, 'male', 'AA008B1', 1),
(7, 'AA444', 'SpiceJet', 'Economy', '2019-11-18 ', '15:00:00', 2954, 'Kushwanth_P', NULL, NULL, 'male', 'AA444E1', 8),
(15, 'AA008', 'Air India', 'Business', '2019-11-16 ', '13:00:00', 43740, 'Dinosaur', NULL, NULL, 'male', 'AA008B4', 1),
(26, 'AA100', 'SpiceJet', 'Economy', '2019-12-02 ', '18:35:00', 4740, 'megha', 's', 'v', 'female', 'AA100E1', 40),
(27, 'AA204', 'Qantas', 'Business', '2019-12-02 ', '10:00:00', 40025, 'abdfes', 'beldale', 'g', 'female', 'AA204B1', 41),
(28, 'AA204', 'Qantas', 'Business', '2019-12-02 ', '10:00:00', 40025, 'gagan', 'r', 'g', 'male', 'AA204B2', 42),
(29, 'AA200', 'IndiGo', 'Economy', '2019-12-02 ', '11:00:00', 40100, 'porcupine', 'beldale', 'fr', 'female', 'AA200E1', 43),
(30, 'AA510', 'SpiceJet', 'Business', '2019-12-03 ', '18:00:00', 27200, 'gagan', 's', 'p', 'male', 'AA510B1', 44);

-- --------------------------------------------------------

--
-- Table structure for table `user`
--

DROP TABLE IF EXISTS `user`;
CREATE TABLE IF NOT EXISTS `user` (
  `username` varchar(20) NOT NULL,
  `first_name` varchar(20) NOT NULL,
  `middle_name` varchar(20) DEFAULT NULL,
  `last_name` varchar(20) NOT NULL,
  `email` varchar(30) NOT NULL,
  `phone` varchar(10) NOT NULL,
  `gender` enum('Male','Female') NOT NULL,
  `password` varchar(20) NOT NULL,
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `user`
--

INSERT INTO `user` (`username`, `first_name`, `middle_name`, `last_name`, `email`, `phone`, `gender`, `password`) VALUES
('kent', 'Kentucky', NULL, 'P', 'k1234@gmail.com', '985674123', 'Male', '123456'),
('sanju', 'sanjana', NULL, 'n r', 'sanjana@gmail.com', '4849845546', 'Female', '123456');

--
-- Constraints for dumped tables
--

--
-- Constraints for table `booking`
--
ALTER TABLE `booking`
  ADD CONSTRAINT `flight_class_fk` FOREIGN KEY (`flight_no`,`class_type`) REFERENCES `class` (`flight_no`, `class`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `user_fk` FOREIGN KEY (`booked_by`) REFERENCES `user` (`username`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `class`
--
ALTER TABLE `class`
  ADD CONSTRAINT `flight_number_fk` FOREIGN KEY (`flight_no`) REFERENCES `flights` (`number`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `flights`
--
ALTER TABLE `flights`
  ADD CONSTRAINT `airplane_id` FOREIGN KEY (`airplane_id`) REFERENCES `airplane` (`model_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `arrival_fk` FOREIGN KEY (`arrival`) REFERENCES `airport` (`city_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `departure_fk` FOREIGN KEY (`departure`) REFERENCES `airport` (`city_id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `ticket`
--
ALTER TABLE `ticket`
  ADD CONSTRAINT `booking_book_id` FOREIGN KEY (`book_id`) REFERENCES `booking` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;
--
-- Database: `mobile`
--
CREATE DATABASE IF NOT EXISTS `mobile` DEFAULT CHARACTER SET latin1 COLLATE latin1_swedish_ci;
USE `mobile`;
--
-- Database: `pizza ordering system`
--
CREATE DATABASE IF NOT EXISTS `pizza ordering system` DEFAULT CHARACTER SET latin1 COLLATE latin1_swedish_ci;
USE `pizza ordering system`;

-- --------------------------------------------------------

--
-- Table structure for table `order`
--

DROP TABLE IF EXISTS `order`;
CREATE TABLE IF NOT EXISTS `order` (
  `Items` varchar(30) NOT NULL,
  `Quantity` varchar(30) NOT NULL,
  `Price` varchar(30) NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `payment`
--

DROP TABLE IF EXISTS `payment`;
CREATE TABLE IF NOT EXISTS `payment` (
  `first name` varchar(30) NOT NULL,
  `last name` varchar(30) NOT NULL,
  `Address` varchar(30) NOT NULL,
  `provinces` varchar(30) NOT NULL,
  `city` varchar(30) NOT NULL,
  `postal code` varchar(30) NOT NULL,
  `contact no` varchar(30) NOT NULL,
  `Email` varchar(30) NOT NULL,
  `payment MethodC` varchar(30) NOT NULL,
  `Card no` varchar(30) NOT NULL,
  `Amount due` varchar(30) NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `pizza`
--

DROP TABLE IF EXISTS `pizza`;
CREATE TABLE IF NOT EXISTS `pizza` (
  `pizza_size` varchar(30) NOT NULL,
  `pizza_type` varchar(30) NOT NULL,
  `Topping` varchar(30) NOT NULL,
  `Drinks` varchar(30) NOT NULL,
  `Other Items` varchar(30) NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
--
-- Database: `store`
--
CREATE DATABASE IF NOT EXISTS `store` DEFAULT CHARACTER SET latin1 COLLATE latin1_swedish_ci;
USE `store`;

-- --------------------------------------------------------

--
-- Table structure for table `brands`
--

DROP TABLE IF EXISTS `brands`;
CREATE TABLE IF NOT EXISTS `brands` (
  `brand_id` int(11) NOT NULL AUTO_INCREMENT,
  `brand_name` varchar(255) NOT NULL,
  `brand_active` int(11) NOT NULL DEFAULT '0',
  `brand_status` int(11) NOT NULL DEFAULT '0',
  PRIMARY KEY (`brand_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `categories`
--

DROP TABLE IF EXISTS `categories`;
CREATE TABLE IF NOT EXISTS `categories` (
  `categories_id` int(11) NOT NULL AUTO_INCREMENT,
  `categories_name` varchar(255) NOT NULL,
  `categories_active` int(11) NOT NULL DEFAULT '0',
  `categories_status` int(11) NOT NULL DEFAULT '0',
  PRIMARY KEY (`categories_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `orders`
--

DROP TABLE IF EXISTS `orders`;
CREATE TABLE IF NOT EXISTS `orders` (
  `order_id` int(11) NOT NULL AUTO_INCREMENT,
  `order_date` date NOT NULL,
  `client_name` varchar(255) NOT NULL,
  `client_contact` varchar(255) NOT NULL,
  `sub_total` varchar(255) NOT NULL,
  `vat` varchar(255) NOT NULL,
  `total_amount` varchar(255) NOT NULL,
  `discount` varchar(255) NOT NULL,
  `grand_total` varchar(255) NOT NULL,
  `paid` varchar(255) NOT NULL,
  `due` varchar(255) NOT NULL,
  `payment_type` int(11) NOT NULL,
  `payment_status` int(11) NOT NULL,
  `payment_place` int(11) NOT NULL,
  `gstn` varchar(255) NOT NULL,
  `order_status` int(11) NOT NULL DEFAULT '0',
  `user_id` int(11) NOT NULL,
  PRIMARY KEY (`order_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `order_item`
--

DROP TABLE IF EXISTS `order_item`;
CREATE TABLE IF NOT EXISTS `order_item` (
  `order_item_id` int(11) NOT NULL AUTO_INCREMENT,
  `order_id` int(11) NOT NULL DEFAULT '0',
  `product_id` int(11) NOT NULL DEFAULT '0',
  `quantity` varchar(255) NOT NULL,
  `rate` varchar(255) NOT NULL,
  `total` varchar(255) NOT NULL,
  `order_item_status` int(11) NOT NULL DEFAULT '0',
  PRIMARY KEY (`order_item_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `product`
--

DROP TABLE IF EXISTS `product`;
CREATE TABLE IF NOT EXISTS `product` (
  `product_id` int(11) NOT NULL AUTO_INCREMENT,
  `product_name` varchar(255) NOT NULL,
  `product_image` text NOT NULL,
  `brand_id` int(11) NOT NULL,
  `categories_id` int(11) NOT NULL,
  `quantity` varchar(255) NOT NULL,
  `rate` varchar(255) NOT NULL,
  `active` int(11) NOT NULL DEFAULT '0',
  `status` int(11) NOT NULL DEFAULT '0',
  PRIMARY KEY (`product_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `users`
--

DROP TABLE IF EXISTS `users`;
CREATE TABLE IF NOT EXISTS `users` (
  `user_id` int(11) NOT NULL AUTO_INCREMENT,
  `username` varchar(255) NOT NULL,
  `password` varchar(255) NOT NULL,
  `email` varchar(255) NOT NULL,
  PRIMARY KEY (`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=latin1;

--
-- Dumping data for table `users`
--

INSERT INTO `users` (`user_id`, `username`, `password`, `email`) VALUES
(1, 'admin', '21232f297a57a5a743894a0e4a801fc3', '');
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
