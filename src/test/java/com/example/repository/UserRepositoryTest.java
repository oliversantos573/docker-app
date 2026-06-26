package com.example.repository;

import com.example.model.User;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.orm.jpa.DataJpaTest;
import org.springframework.test.context.TestPropertySource;

import java.util.List;

import static org.junit.jupiter.api.Assertions.*;

@DataJpaTest
@TestPropertySource(properties = {
        "spring.datasource.url=jdbc:h2:mem:testdb",
        "spring.datasource.driverClassName=org.h2.Driver",
        "spring.jpa.database-platform=org.hibernate.dialect.H2Dialect",
        "spring.h2.console.enabled=true"
})
public class UserRepositoryTest {

    @Autowired
    private UserRepository userRepository;

    @BeforeEach
    void setUp() {
        userRepository.deleteAll();
    }

    @Test
    void testSaveUser() {
        User user = new User("Carlos", "carlos@example.com", "123456789");
        User saved = userRepository.save(user);

        assertNotNull(saved.getId());
        assertEquals("Carlos", saved.getName());
        assertEquals("carlos@example.com", saved.getEmail());
    }

    @Test
    void testFindById() {
        User user = new User("Diana", "diana@example.com", "987654321");
        User saved = userRepository.save(user);

        User found = userRepository.findById(saved.getId()).orElse(null);

        assertNotNull(found);
        assertEquals("Diana", found.getName());
    }

    @Test
    void testFindAll() {
        userRepository.save(new User("User1", "user1@example.com", "111111111"));
        userRepository.save(new User("User2", "user2@example.com", "222222222"));

        List<User> users = userRepository.findAll();

        assertEquals(2, users.size());
    }

    @Test
    void testDeleteUser() {
        User user = new User("Eduardo", "edu@example.com", "333333333");
        User saved = userRepository.save(user);

        userRepository.delete(saved);

        assertTrue(userRepository.findById(saved.getId()).isEmpty());
    }
}
